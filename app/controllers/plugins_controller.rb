class PluginsController < ApplicationController
  before_action :log_access
  after_action :allow_iframes

  include CoursesHelper

	def index
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @courses = current_user.courses.order(:name)
    elsif params[:school_id].present?
      @school = School.find(params[:school_id])
      if params[:search].present?
        search_term = ""
        params[:search].split(" ").each do |word|
          search_term << "#{word.singularize} "
        end
        search_term = search_term.strip
        search = Course.search do
          fulltext search_term
          paginate per_page: 500
        end
        @courses = search.results
        ids = Array.new
        @courses.each do |course|
          ids << course.id
        end
        if @courses.present?
          @courses = @school.courses.where(id: ids).order("FIELD(id, #{ids.join(',')})")
        else
          @courses = Course.none
        end
      else
        @courses = @school.courses
      end
      @departments = @courses.pluck(:department).uniq.sort
      if params[:departments].present?
        @courses = @courses.where(department: params[:departments])
      end
      if params[:order] == "dept"
        if params[:dir] == "desc"
          @courses = @courses.reorder("department DESC", :number)
        else
          @courses = @courses.reorder(:department, :number)
        end
      else
        if params[:dir] == "desc"
          @courses = @courses.reorder("name DESC")
        else
          @courses = @courses.reorder(:name)
        end
      end
      @courses = @courses.paginate(page: params[:page])
    else
      search_courses
    end
    @tab = "courses"
    if request.xhr?
      params["_"] = nil
      form_html = render_to_string(partial: 'courses/search_form')
      results_html = render_to_string(partial: 'courses/results')
      tabs_html = render_to_string(partial: 'tabs')
      new_url = @school.present? ? plugin_school_path(@school) : plugin_path
      respond_to do |format|
        msg = { results_html: results_html, form_html: form_html, tabs_html: tabs_html, new_url: new_url }
        format.json  { render :json => msg }
      end
    end
	end

  def sessions
    params[:semester] ||= semesters[0]
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @courses = current_user.courses.order(:name)
    elsif params[:school_id].present?
      @school = School.find(params[:school_id])
      if params[:search].present?
        search_term = ""
        params[:search].split(" ").each do |word|
          search_term << "#{word.singularize} "
        end
        search_term = search_term.strip
        search = Course.search do
          fulltext search_term
          paginate per_page: 500
        end
        @courses = search.results
        ids = Array.new
        @courses.each do |course|
          ids << course.id
        end
        if @courses.present?
          @courses = @school.courses.where(id: ids).order("FIELD(id, #{ids.join(',')})")
        end
      else
        @courses = @school.courses.order(:name)
      end
    elsif params[:search].present?
      search_courses
      if session[:latitude].present? && session[:longitude].present?
        ids = Array.new
        @courses_query.each do |course|
          ids << course.id
        end
        if @courses.present?
          @courses = Course.where(id: ids).order("FIELD(id, #{ids.join(',')})")
        end
      end
    end
    if @courses.present? && @courses.count > 0
      if @school.present?
        if params[:search].present?
          @sessions = Session.includes(:course).where(semester: params[:semester], course_id: @courses.pluck(:id)).order("FIELD(course_id, #{@courses.pluck(:id).join(',')})")
        else
          @sessions = Session.includes(:course).where(semester: params[:semester], course_id: @courses.pluck(:id)).order("courses.name")
        end
      else
        @sessions = Session.includes(:course).where(semester: params[:semester], course_id: @courses.pluck(:id)).order("FIELD(course_id, #{@courses.pluck(:id).join(',')})")
      end
      if params[:meeting].nil? || (params[:meeting].present? && !params[:meeting].include?('online'))
        if params[:days].present?
          @sessions = filter_sessions_days(@sessions)
        end
        if params[:start_time].present?
          @sessions = @sessions.where("start_time >= ?", Time.parse(params[:start_time]).strftime("%H:%M:%S"))
        end
        if params[:end_time].present?
          @sessions = @sessions.where("end_time <= ?", Time.parse(params[:end_time]).strftime("%H:%M:%S"))
        end
      end
      if params[:departments].present?
        @sessions = @sessions.where(['courses.department IN (?)', params[:departments]])
      end
      if params[:meeting].present?
        meeting = params[:meeting]
        if meeting.include?('classroom') && !meeting.include?('online')
          @sessions = @sessions.where("online IS NULL")
        elsif !meeting.include?('classroom') && meeting.include?('online')
          @sessions = @sessions.where("online = 1")
        end
      end
      if @school.nil?
        @session_count = @sessions.count
        @sessions = @sessions.group_by { |session| session.course.school }
        @sessions = @sessions.sort_by { |school, sessions| school.distance_from([session[:latitude], session[:longitude]]) }
      else
        @departments = @school.courses.pluck(:department).uniq.sort
        @courses = @courses.paginate(page: params[:page])
        @sessions = @sessions.paginate(page: params[:page])
      end
    end
    if params[:page].nil? && (params[:search].present? || params[:days].present? || params[:start_time].present? || params[:end_time].present? || params[:departments].present? || params[:meeting].present?)
      @session_search = SessionSearch.new(latitude: session[:latitude], longitude: session[:longitude], ip_address: request.remote_ip)
      @session_search.search = params[:search].present? ? params[:search] : nil
      @session_search.sunday = params[:days].present? && params[:days].include?('sunday') ? 1 : nil
      @session_search.monday = params[:days].present? && params[:days].include?('monday') ? 1 : nil
      @session_search.tuesday = params[:days].present? && params[:days].include?('tuesday') ? 1 : nil
      @session_search.wednesday = params[:days].present? && params[:days].include?('wednesday') ? 1 : nil
      @session_search.thursday = params[:days].present? && params[:days].include?('thursday') ? 1 : nil
      @session_search.friday = params[:days].present? && params[:days].include?('friday') ? 1 : nil
      @session_search.saturday = params[:days].present? && params[:days].include?('saturday') ? 1 : nil
      @session_search.start_time = params[:start_time]
      @session_search.end_time = params[:end_time]
      @session_search.classroom = params[:meeting].present? && params[:meeting].include?('classroom') ? 1 : nil
      @session_search.online = params[:meeting].present? && params[:meeting].include?('online') ? 1 : nil
      if @school.present?
        @session_search.school_id = @school.id
      end
      @session_search.save
    end
    @tab = "sessions"
    if request.xhr?
      params["_"] = nil
      form_html = render_to_string(partial: 'courses/search_form')
      results_html = render_to_string(partial: 'courses/results')
      tabs_html = render_to_string(partial: 'tabs')
      new_url = @school.present? ? plugin_school_sessions_path(@school) : plugin_sessions_path
      respond_to do |format|
        msg = { results_html: results_html, form_html: form_html, tabs_html: tabs_html, new_url: new_url }
        format.json  { render :json => msg }
      end
    end
  end

	private

		def search_courses
      if params[:location].present?
        if params[:location] == session[:location_name]
          session[:location_method] = 'geocoder'
        else
          geo = Geocoder.search(params[:location])
          store_geolocation(geo[0].coordinates[0], geo[0].coordinates[1], geo[0].city, geo[0].state_code, 'geocoder')
        end
      end

      if session[:latitude].present? && session[:longitude].present? && params[:search].present?
        latitude = session[:latitude]
        longitude = session[:longitude]
        search_term = ""
        params[:search].split(" ").each do |word|
          search_term << "#{word.singularize} "
        end
        search_term = search_term.strip
        search = Course.search do
          fulltext search_term
          with(:location).in_radius(session[:latitude], session[:longitude], 1000, :bbox => true)
          paginate per_page: 500
        end
        @courses_query = search.results
        @course_count = @courses_query.count
        @courses = @courses_query.group_by { |course| course.school }
        @courses = @courses.sort_by { |school, courses| school.distance_from([latitude, longitude]) }
      end
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
      Date::DAYNAMES.each_with_index do |day, i|
        day = day.downcase
        if !params[:days].include?(day) && Session.column_names.include?(day)
          days_off << "#{day} IS NULL"
          if i < (8 - params[:days].count)
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

    def allow_iframes
      response.headers.except! 'X-Frame-Options'
    end

    def log_access
      geo = Geocoder.search(request.remote_ip)
      if geo.present?
        latitude = geo[0].latitude
        longitude = geo[0].longitude
      end
      if params[:school_id].present?
        school = School.find(params[:school_id])
        access = school.plugin_accesses.create(remote_ip: request.remote_ip, latitude: latitude, longitude: longitude, referer: request.referer)
      else
        access = PluginAccess.create(remote_ip: request.remote_ip, latitude: latitude, longitude: longitude, referer: request.referer)
      end
      if request.referer.present? && !request.referer.include?(request.host)
        session[:referer] = request.referer
      end
    end
end
