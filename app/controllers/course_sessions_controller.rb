class CourseSessionsController < ApplicationController
	include CoursesHelper
  include SchoolsHelper

	before_action :get_school, except: [:index]
  before_action :signed_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:import, :edit, :update, :destroy]
  before_action :check_location, only: :index

	def index
		params[:semester] ||= semesters[0]
    @courses = Course.none
    @sessions = Session.none
    if params[:school_id].present?
      @school = School.find(params[:school_id])
      if params[:search].present?
        search_term = ""
        params[:search].split(" ").each do |word|
          search_term << "#{word.singularize} "
        end
        search_term = search_term.strip
        search_ids = Course.search_ids do
          fulltext search_term
          paginate per_page: 100000
        end
        ids = search_ids
        if ids.any?
          @courses = @school.courses.where(id: ids).order("FIELD(id, #{ids.join(',')})")
        else
          @courses = Course.none
        end
      else
        @courses = @school.courses.order(:name)
      end
    elsif params[:search].present?
      search = search_courses
    end
    if search.present? && search.any?
      filter_sessions(search)
    elsif @courses.count > 0
      filter_sessions(@courses.pluck(:id))
    end
    set_error_alerts
    set_courses_url
    check_distance
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

	def edit_index
		@edit = true
    index
    if !request.xhr?
      render 'index'
    end
  end

  def new
    @session = Session.new
  end

  def create
    @session = Session.new
    if @session.update_attributes(course_session_params)
      flash[:success] = "Course Session Created!"
      redirect_to school_edit_sessions_path(@school)
    else
      render 'edit'
    end
  end

	def edit
		@session = Session.find(params[:id])
	end

	def update
		@session = Session.find(params[:id])
  	if @session.update_attributes(course_session_params)
      flash[:success] = "Course Session Updated!"
      redirect_to school_edit_sessions_path(@school)
    else
      render 'edit'
    end
	end

  def destroy
    @session = Session.find(params[:id]).destroy
    flash[:success] = "Course session deleted."
    redirect_to school_edit_sessions_path(@school)
  end

	private

    def session_params
      params.require(:session).permit(:crn, :credits,
        :semester_id, :location, :room, :online, :sunday, :monday,
        :tuesday, :wednesday, :thursday, :friday, :saturday)
    end

    def course_session_params
      params.require(:session).permit(:crn, :credits,
      	:semester_id, :location, :room, :online, :sunday, :monday,
      	:tuesday, :wednesday, :thursday, :friday, :saturday,
      	:course_attributes => [:name, :description, :department, :number, :school_id])
    end

    #before filters

    def correct_user
      redirect_to(root_url) unless (@school.users.exists?(current_user) || admin_user)
    end

		def get_school
      @school = School.find(params[:school_id])
    end

    def save_search
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
    end

    def set_error_alerts
      if @school.present?
        if @school.courses.empty?
          if @edit
            flash.now[:info] = "This school does not have any courses listed on Classhunters yet.<br>To get started, you can #{view_context.link_to 'create a course session', school_new_session_path(@school)} or #{view_context.link_to 'import courses from a CSV file', school_import_courses_path(@school)}.".html_safe
          else
            flash.now[:info] = "To view course offerings for this institution, click #{view_context.link_to "here", school_website_url(@school), target: '_blank'} to visit the school's website.".html_safe
          end
        elsif @sessions.nil? && !params[:search].present?
          flash.now[:info] = "Please enter a search term"
        elsif @sessions.empty?
          flash.now[:info] = "There are no courses matching your search terms."
        end
      else
        if @sessions.empty?
          if params[:search].present?
            if location_set?
              flash.now[:info] = "There are no course sessions matching your search terms."
            else
              flash.now[:info] = "Please specify a location."
            end
          else
            flash.now[:info] = "Please enter a search term."
          end
        end
      end
    end

    def filter_sessions(ids)
      semester = Semester.find(params[:semester])
      if @school.present?
        if params[:search].present?
          @sessions = semester.sessions.includes(:course).where(course_id: ids).order("FIELD(course_id, #{ids.join(',')})")
        else
          @sessions = semester.sessions.includes(:course).where(course_id: ids).order("courses.name")
        end
      else
        if params[:school_type].present?
          ids = Course.includes(:school).where(id: ids, "schools.category" => params[:school_type]).pluck(:id)
          @sessions = semester.sessions.includes(:course).where(course_id: ids).order("FIELD(course_id, #{ids.join(',')})")
        else
          @sessions = semester.sessions.includes(:course).where(course_id: ids).order("FIELD(course_id, #{ids.join(',')})")
        end
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

    def set_courses_url
      if params[:search].present?
        if @school.present?
          if @edit
            @courses_path = school_edit_courses_path(@school, search: params[:search]) 
          else 
            @courses_path = school_courses_path(@school, search: params[:search]) 
          end 
        else 
          @courses_path = courses_path(search: params[:search]) 
        end 
      else 
        if @school.present? 
          if @edit 
            @courses_path = school_edit_courses_path(@school)
          else 
            @courses_path = school_courses_path(@school) 
          end 
        else 
          @courses_path = courses_path 
        end 
      end 
    end

end
