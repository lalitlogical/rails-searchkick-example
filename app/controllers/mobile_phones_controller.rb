class MobilePhonesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_mobile_phone, only: [:show]

  # GET /mobile_phones
  # GET /mobile_phones.json
  def index
    @mobile_phones = MobilePhone._search(params)
    @categories = {}
    @mobile_phones.aggs.keys.sort.each do |category|
      @categories[category] = @mobile_phones.aggs[category]["buckets"].sort_by{ |e| e["key"] }
    end
  end

  # GET /mobile_phones/1
  # GET /mobile_phones/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mobile_phone
      @mobile_phone = MobilePhone.friendly.find(params[:id])
    end
end
