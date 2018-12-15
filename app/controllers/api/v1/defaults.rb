module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json

        helpers do
          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def logger
            Rails.logger
          end

          def render_object object, serializer, options = {}
            json_success_response({
              data: single_serializer.new(object, serializer: serializer)
            })
          end

          def format_aggregation aggregation
            aggregation.each do |k,value|
              value['total_count'] = value.delete("doc_count")
              value.delete("doc_count_error_upper_bound")
              value.delete("sum_other_doc_count")
              value['buckets'].each do |bucket|
                bucket['count'] = bucket.delete("doc_count")
              end
              # aggregation[k] = value['buckets']
            end
            { aggregation: aggregation }
          end

          def render_collection objects, serializer, options = {}
            meta = {}
            meta.merge!(options[:extra_params]) if options[:extra_params].present?
            meta.merge!({suggestions: suggestions}) if objects.respond_to?(:suggestions) && objects.suggestions.present?
            meta.merge!(format_aggregation(objects.aggs)) if objects.respond_to?(:aggs) && objects.aggs.present?
            if objects.respond_to?(:total_count)
              meta.merge!({
                total_count: objects.total_count,
                current_page: objects.current_page,
                next_page: objects.next_page,
                per_page: objects.limit_value
              })
            end

            # send data & meta
            json_success_response({
              data: array_serializer.new(objects, serializer: serializer),
              meta: meta
            })
          end

          def array_serializer
            ActiveModel::Serializer::CollectionSerializer
          end

          def single_serializer
            ActiveModelSerializers::SerializableResource
          end

          def json_success_response response = {}, status_code = 200
            { success: true, status: status_code }.merge(response)
          end

          def json_error_response response = {}, status_code = (ENV['STATUS_CODE'] || 422)
            error!({ success: false, status: status_code }.merge(response), status_code)
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end

        # global exception handler, used for error notifications
        # Catch exception and return JSON-formatted error
        rescue_from :all do |e|
          raise e
          json_error_response({
            errors: ["Internal server error."]
          }, 500)
        end
      end
    end
  end
end
