class MobilePhone < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  searchkick word_start: [:name, :brand, :description]

  def self._search params
    search_text = params[:search].present? ? params[:search] : '*'

    query = {}
    [:brand, :ram, :screen_size, :sim_type, :primary_camera, :secondary_camera].each do |key|
      query[key] = params[key] if params[key].present?
    end

    return self.search search_text,
      fields: [:name, :brand, :description],
      order: {_score: :desc},
      where: query,
      limit: 12, offset: params[:page],
      aggs: [:brand, :ram, :screen_size, :sim_type, :primary_camera, :secondary_camera]

  end
end
