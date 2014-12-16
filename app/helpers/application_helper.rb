module ApplicationHelper
	# Generates the page title
  # @param page_title The string to append to the page title
  # @return String of the full page title
	def full_title(page_title)
		base_title = 'Classhunters'
		if page_title.empty?
			"#{base_title} | Find A Class Near You"
		else
			"#{base_title} | #{page_title}"
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
    string = ''
    crumbs.each do |crumb, url|
      if url.present?
        string += link_to crumb, url
      else
        string += crumb
      end
      string += ' > '
    end
    provide :crumbs, string[0..string.length-4].html_safe
  end
end
