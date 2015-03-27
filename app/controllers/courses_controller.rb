class CoursesController < ApplicationController
  require 'csv'

  include CoursesHelper
  
  before_action :get_school, except: [:index, :add_to_user, :remove_from_user, :saved]
	before_action :signed_in_user, only: [:new, :create, :edit, :update, :destroy]
	before_action :correct_user, only: [:import, :edit, :update, :destroy]

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
          paginate per_page: 9999999
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
        @courses = @school.courses.order(:name)
      end
      @departments = @courses.pluck(:department).uniq.sort
      if params[:departments].present?
        @courses = @courses.where(department: params[:departments])
      end
      @courses = @courses.paginate(page: params[:page])
    else
      search_courses
    end
    if params[:search].present? && params[:page].nil?
      if @school.present?
        @course_search = CourseSearch.create!(search: params[:search], latitude: session[:latitude], longitude: session[:longitude], ip_address: request.remote_ip, school_id: @school.id)
      else
        @course_search = CourseSearch.create!(search: params[:search], latitude: session[:latitude], longitude: session[:longitude], ip_address: request.remote_ip)
      end
    end
    if request.xhr?
      params["_"] = nil
      form_html = render_to_string(partial: 'search_form')
      results_html = render_to_string(partial: 'results')
      respond_to do |format|
        msg = { results_html: results_html, form_html: form_html }
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
          paginate per_page: 9999999
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
    if request.xhr?
      params["_"] = nil
      form_html = render_to_string(partial: 'search_form')
      results_html = render_to_string(partial: 'results')
      respond_to do |format|
        msg = { results_html: results_html, form_html: form_html }
        format.json  { render :json => msg }
      end
    end
  end

	def new
		@course = @school.courses.build
	end

	def create
    @course = @school.courses.build(course_params)
    if @course.save
      flash[:success] = "Course created!"
      redirect_to school_course_path(@school, @course)
    else
      render 'new'
    end
  end

  def show
		@course = @school.courses.find(params[:id])
    @sessions = @course.sessions
    @sessions = @sessions.group_by(&:semester)
	end

	def edit
		@course = @school.courses.find(params[:id])
  end

  def update
		@course = @school.courses.find(params[:id])
  	if @course.update_attributes(course_params)
      flash[:success] = "Course Updated!"
      redirect_to school_course_path(@school, @course)
    else
      render 'edit'
    end
  end

  def destroy
		@course = @school.courses.find(params[:id]).destroy
    flash[:success] = "Course deleted."
    redirect_to school_courses_path(@school)
  end

  def import
    if params[:file].present?
      file = params[:file]
      file.tempfile.binmode
      file.tempfile = Base64.encode64(file.tempfile.read)
      Resque.enqueue(CourseImporter, file, @school.id, params[:semester], params[:type])
      redirect_to school_courses_path(@school), notice: "Courses are being imported."
    end
  end

  def add_to_user
    @course = Course.find(params[:course_id])
    if !current_user.courses.exists?(@course)
      current_user.courses << @course
      respond_to do |format|
        msg = { status: "ok", message: "Success!" }
        format.json  { render :json => msg }
      end
    else
      respond_to do |format|
        msg = { status: "fail", message: "Class is already saved!" }
        format.json  { render :json => msg }
      end
    end
  end

  def remove_from_user
    @course = Course.find(params[:course_id])
    if current_user.courses.exists?(@course)
      current_user.courses.delete(@course)
      redirect_to user_courses_path(current_user)
    end
  end

  def json
    if params[:course_id].present?
      session = nil
      course = Course.find(params[:course_id])
      html = render_to_string(partial: 'dropdown_info', locals: { course: course, session: session })
    elsif params[:session_id].present?
      session = Session.find(params[:session_id])
      course = session.course
      html = render_to_string(partial: 'dropdown_info', locals: { course: course, session: session })
    end
    respond_to do |format|
      msg = { html: html }
      format.json  { render :json => msg }
    end
  end

  def get_results
    if params[:semester].present?
      sessions
      form_html = render_to_string(partial: 'search_form')
      results_html = render_to_string(partial: 'results')
    else
      index
      form_html = render_to_string(partial: 'search_form')
      results_html = render_to_string(partial: 'results')
    end
    if request.xhr?
      respond_to do |format|
        msg = { results_html: results_html, form_html: form_html }
        format.json  { render :json => msg }
      end
    else
      render(partial: 'results')
    end
  end

  private

    def course_params
      params.require(:course).permit(:name, :description,
      	:department, :number, :school_id)
    end

    # Before filters

    def correct_user
      redirect_to(root_url) unless (@school.users.exists?(current_user) || admin_user)
    end

    def get_school
      @school = School.find(params[:school_id])
    end

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
end
