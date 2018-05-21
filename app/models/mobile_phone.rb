class MobilePhone < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  searchkick word_start: [:name, :brand, :description], suggest: [:name], highlight: [:name]

  def highlighted_value_of key
    text = try(:search_highlights).try(:[], key) || send(key)
    text.gsub(/15.*/,'').html_safe
  end

  def self._search params
    search_text = params[:search].present? ? params[:search] : '*'

    query = {}
    [:brand, :ram, :screen_size, :sim_type, :primary_camera, :secondary_camera].each do |key|
      query[key] = params[key].split(',') if params[key].present?
    end

    return self.search search_text,
      fields: [:name, :brand, :description],
      order: {_score: :desc},
      where: query,
      limit: 12, offset: params[:page],
      suggest: true,
      highlight: true,
      misspellings: { below: 5 },
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
