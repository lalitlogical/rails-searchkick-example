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

  def prepare_url category_name, option
    url = request.url
    option_name = (option["key"] || option[:key]).to_s
    old_search_string = request.url.match(/\?/) ? request.url.split('?').last : ""
    search_string = old_search_string.split('&').delete_if { |q| q.match(category_name).present? }
    search_string << "#{category_name}=#{option_name}"
    "/?#{search_string.join('&')}"
  end

  def query_string?
    request.url.match(/\?/).present?
  end

  def prepare_query_tag
    close_btn = '<span aria-hidden="true">&times;</span>'
    links = []
    old_search_string = request.url.match(/\?/) ? request.url.split('?').last : ""
    search_strings = old_search_string.split('&')
    search_strings.each do |tag|
      key_value = tag.split('=')
      category_name = key_value.first
      value = key_value.last
      link_text = "#{category_name.humanize} (#{value.humanize}) #{close_btn}".html_safe
      query = search_strings.reject { |q| q.match(category_name).present? }
      links << link_to(link_text, "?#{query.join('&')}", class: 'btn btn-primary')
    end
    links.join.html_safe
  end
end
