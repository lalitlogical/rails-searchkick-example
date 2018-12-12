module MobilePhonesHelper

  def prepare_name category_name, option
    option_name = (option["key"] || option[:key]).to_s
    t = case category_name
    when "primary_camera", "secondary_camera"
      "#{option_name} MP"
    when "ram"
      "#{option_name} GB"
    when "screen_size"
      "#{option_name} \""
    else
      option_name.to_s.humanize
    end
    "#{t} (#{option["doc_count"]})"
  end

  def old_search_string
    @q_string ||= request.url.match(/\?/) ? request.url.split('?').last : ""
  end

  def prepare_url category_name, option, checked = false
    url = request.url
    option_name = (option["key"] || option[:key]).to_s
    value = (option["value"] || option[:value]).to_s

    search_string = old_search_string.split('&').delete_if { |q| q.match(category_name).present? }
    current_option = old_search_string.split('&').find { |q| q.match(category_name).present? }

    if value.blank?
      values = current_option.present? ? current_option.gsub(/.*=/,'').split(',') : []
      checked ? values.delete_if { |v| v == option_name } : (values << option_name).uniq
    else
      (values = []) << value
    end

    search_string << "#{category_name}=#{values.join(',')}" if values.present?
    "#{category_name == 'search' ? '/' : ''}?#{search_string.join('&')}"
  end

  def is_checked category_name, option
    option_name = (option["key"] || option[:key]).to_s
    current_option ||= old_search_string.split('&').find { |q| q.match(category_name).present? }
    values = current_option.present? ? current_option.split(/=/).last.split(',') : []
    values.include?(option_name) ? 'checked' : ''
  end

  def query_string?
    request.url.match(/\?/).present?
  end

  def prepare_query_tag
    close_btn = '<span aria-hidden="true">&times;</span>'
    links = []
    search_strings = old_search_string.split('&')
    search_strings.each do |tag|
      key_value = tag.split('=')
      category_name = key_value.first
      # value = key_value.last
      # (#{value.humanize})
      link_text = "#{category_name.humanize} #{close_btn}".html_safe
      query = search_strings.reject { |q| q.match(category_name).present? }
      links << link_to(link_text, "?#{query.join('&')}", class: 'btn btn-primary')
    end
    links.join.html_safe
  end

  def prepare_suggestion_tag
    links = []
    @suggestions.each do |s|
      links << link_to(s, "?search=#{s}", class: 'btn btn-primary')
    end
    links.join.html_safe
  end

  def number_to_human_for count
    number_to_human(count, :format => '%n%u', :units => { :thousand => 'K', :million => 'M', :billion => 'B' })
  end

  def sorting_tabs
    {
      "Popularity": "_score",
      "Price -- Low to High": "price_asc",
      "Price -- High to Low": "price_desc",
      "Newest First": "newest"
    }
  end
end
