class MobilePhone < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  searchkick word_start: [:name, :brand, :description], suggest: [:name], highlight: [:name]

  def highlighted_value_of key
    text = try(:search_highlights).try(:[], key) || send(key)
    text.gsub(/15.*/,'').html_safe
  end

  def self._search params
    # searching text
    search_text = params[:search].present? ? params[:search] : '*'

    # filtering logic
    query = {}
    [:brand, :ram, :screen_size, :sim_type, :primary_camera, :secondary_camera].each do |key|
      query[key] = params[key].split(',') if params[key].present?
    end

    # sorting logic
    order = {_score: :desc}
    if params[:sorting].present?
      if params[:sorting] == 'price_asc' or params[:sorting] == 'price_desc'
        order =  { price: params[:sorting].rpartition('_').last.to_sym }
      elsif params[:sorting] == 'newest'
        order =  { created_at: :desc }
      end
    end

    return self.search search_text,
      fields: [:name, :brand, :description],
      order: order,
      where: query,
      suggest: true,
      highlight: true,
      misspellings: { below: 5 },
      page: params[:page], per_page: params[:per_page] || 15,
      aggs: [:brand, :ram, :screen_size, :sim_type, :primary_camera, :secondary_camera]
  end

  def self.autocomplete params
    return self.search(params[:query], {
      fields: ["name^5", "description"],
      match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 5}
    }).map(&:name)
  end
end
