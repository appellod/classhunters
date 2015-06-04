module CoursesHelper
	def days_to_string(session)
		str = ''
		if session.sunday?
			str += 'Su'
		end
		if session.monday?
			str += 'M'
		end
		if session.tuesday?
			str += 'T'
		end
		if session.wednesday?
			str += 'W'
		end
		if session.thursday?
			str += 'R'
		end
		if session.friday?
			str += 'F'
		end
		if session.saturday?
			str += 'S'
		end
		return str
	end

	def semesters_select
		[
			['All Semesters', ''], 'Summer 2015', 'Spring 2015', 'Winter 2014', 'Fall 2014'
		]
	end

	def semesters_array
		arr = []
    Semester.order("position DESC").limit(4).each do |semester|
      temp = ["#{semester.name} #{semester.year}", semester.id]
      arr << temp
    end
    return arr
	end

  def semesters
    Semester.order("position DESC").limit(4)
  end

  def semester_display(semester)
    return "#{semester.name} #{semester.year}"
  end

	def times
		time = Time.parse('2015/1/1')
		times = Array.new
		for i in 0..23
			times << time.strftime('%l:%M%p')
			time += 1.hour
		end
		return times
	end

  def check_location
    if params[:location].present?
      if params[:location] == session[:location_name]
        session[:location_method] = 'geocoder'
      else
        geo = Geocoder.search(params[:location])
        store_geolocation(geo[0].coordinates[0], geo[0].coordinates[1], geo[0].city, geo[0].state_code, 'geocoder')
      end
    end
  end

	def search_courses
      search = []
      if session[:latitude].present? && session[:longitude].present? && params[:search].present?
        latitude = session[:latitude]
        longitude = session[:longitude]
        search_term = ""
        params[:search].split(" ").each do |word|
          search_term << "#{word.singularize} "
        end
        search_term = search_term.strip
        search = Course.search_ids do
          fulltext search_term
          with(:location).in_radius(session[:latitude], session[:longitude], 1000, :bbox => true)
          paginate per_page: 1000
        end
        if search.count == 0
          search = Course.search_ids do
            fulltext search_term
            paginate per_page: 1000
          end
        end
      end
      return search
    end

		def filter_sessions_days(sessions)
      days = ""
      days_off = ""
      params[:days].each_with_index do |day, i|
        if Session.column_names.include?(day)
          days << "#{day} = 1"
          if i < params[:days].count - 1
            days << " OR "
          end
        end
      end
      count = 0
      Date::DAYNAMES.each_with_index do |day, i|
        day = day.downcase
        if !params[:days].include?(day) && Session.column_names.include?(day)
          days_off << "#{day} = 0"
          count += 1
          if count < (7 - params[:days].count)
            days_off << " AND "
          end
        end
      end
      if days_off.present?
        sessions = sessions.where("(#{days}) AND (#{days_off})")
      else
        sessions = sessions.where("#{days}")
      end
      return sessions
    end

    def check_distance
      distance = Geocoder::Calculations.distance_between([session[:latitude],session[:longitude]], [40.526184,-75.064941])
      distance > 125 ? @too_far = true : @too_far = false
    end
end
