module ApplicationHelper
	# Generates the page title
  # @param page_title The string to append to the page title
  # @return String of the full page title
	def full_title(page_title)
		base_title = 'Classhunters'
		if page_title.empty?
			"Find A Class Near You | #{base_title}"
		else
			"#{page_title} | #{base_title}"
		end
	end

	# Returns if the user's device is mobile or not
  # @return True if user's device is mobile, false otherwise
  def mobile?
    is_mobile_device?
  end

  # Returns if the user's device is tablet or not
  # @return True if user's device is tablet, false otherwise
  def tablet?
    is_tablet_device?
  end

  # Returns if the user's device is desktop or not
  # @return True if user's device is desktop, false otherwise
  def desktop?
    !is_mobile_device? && !is_tablet_device?
  end

  def breadcrumbs(crumbs)
    string = '<div class="breadcrumbs" itemscope itemtype="http://data-vocabulary.org/Breadcrumb">'
    i = 0
    crumbs.each do |key, value|
      if i > 0
        string += '<span itemprop="child" itemscope itemtype="http://data-vocabulary.org/Breadcrumb">'
      end
      if value.present?
        string += link_to("<span itemprop=\"title\">#{key}</span>".html_safe, value, itemprop: "url")
      else
        string += link_to("<span itemprop=\"title\">#{key}</span>".html_safe, request.original_url, itemprop: "url")
      end
      string += ' > '
      i += 1
    end
    string = string[0..string.length-4]
    for i in 0..crumbs.count - 1
      string += "</span>"
    end
    string += "</div>"
    provide :crumbs, string.html_safe
  end

  def sortable(display, attribute = nil)
    attribute ||= display.downcase
    if params[:sort] == attribute
      str = link_to display, params.merge({ order: (params[:order] == 'asc' || params[:order].nil?) ?  'des' : 'asc' })
      if params[:order] == 'asc' || params[:order].nil?
        str << " <small>&#x25BC;</small>".html_safe
      else
        str << " <small>&#x25B2;</small>".html_safe
      end
    else
      str = link_to display, params.merge({ order: (params[:order] == 'asc' || params[:order].nil?) ?  'desc' : 'asc', sort: attribute })
    end
    return str
  end

  def preserve_params
    str = ""
    params.each do |param|
      if param[1].is_a? Array
        param[1].each do |arr|
          str << (hidden_field_tag "#{param[0]}[]", arr)
        end
      else
        str << (hidden_field_tag param[0], param[1])
      end
    end
    return str.html_safe
  end
end
