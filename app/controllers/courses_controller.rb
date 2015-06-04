class CoursesController < ApplicationController
  require 'csv'

  include CoursesHelper
  include SchoolsHelper
  
  before_action :get_school, except: [:index, :add_to_user, :remove_from_user, :saved]
	before_action :signed_in_user, only: [:new, :create, :edit, :update, :destroy]
	before_action :correct_user, only: [:import, :edit, :update, :destroy]
  before_action :check_location, only: :index

	def index
    if params[:school_id].present?
      @school = School.find(params[:school_id])
      if params[:search].present?
        search_term = ""
        params[:search].split(" ").each do |word|
          search_term << "#{word.singularize} "
        end
        search_term = search_term.strip
        search = Course.search_ids do
          fulltext search_term
          paginate per_page: 100000
        end
        ids = search
        if ids.any?
          @courses = @school.courses.where(id: ids).order("FIELD(id, #{ids.join(',')})")
        else
          @courses = Course.none
        end
      else
        if params[:order] == "dept"
          if params[:dir] == "desc"
            @courses = @school.courses.order("department DESC", :number)
          else
            @courses = @school.courses.order(:department, :number)
          end
        else
          if params[:dir] == "desc"
            @courses = @school.courses.order("name DESC")
          else
            @courses = @school.courses.order(:name)
          end
        end
      end
      @departments = @courses.pluck(:department).uniq.sort
      if params[:departments].present?
        @courses = @courses.where(department: params[:departments])
      end
      @courses = @courses.paginate(page: params[:page])
      if @school.courses.empty?
        if @edit
          flash.now[:info] = "This school does not have any courses listed on Classhunters yet.<br>To get started, you can #{view_context.link_to 'create a course', new_school_course_path(@school)} or #{view_context.link_to 'import courses from a CSV file', school_import_courses_path(@school)}.".html_safe
        else
          flash.now[:info] = "To view course offerings for this institution, click #{view_context.link_to "here", school_website_url(@school), target: '_blank'} to visit the school's website.".html_safe

        end
      elsif @courses.empty?
        flash.now[:info] = "There are no courses matching your search terms."
      end
    else
      search = search_courses
      if search.any?
        if params[:school_type].present?
          @results = Course.includes(:school).where(id: search, "schools.category" => params[:school_type]).order("FIELD(courses.id, #{search.join(',')})")
        else
          @results = Course.includes(:school).where(id: search).order("FIELD(id, #{search.join(',')})")
        end
        @course_count = @results.count
        @courses = @results.to_a.group_by { |course| course.school }
        @courses = @courses.sort_by { |school, courses| school.distance_from([session[:latitude], session[:longitude]]) }
      end
      if @courses.nil?
        flash.now[:info] = "Please enter a search term."
      elsif @courses.empty? && params[:search].present?
        if location_set?
          flash.now[:info] = "There are no courses matching your search terms."
        else
          flash.now[:info] = "Please specify a location."
        end
      end
    end
    if params[:search].present? && params[:page].nil?
      if @school.present?
        @course_search = CourseSearch.create!(search: params[:search], latitude: session[:latitude], longitude: session[:longitude], ip_address: request.remote_ip, school_id: @school.id)
      else
        @course_search = CourseSearch.create!(search: params[:search], latitude: session[:latitude], longitude: session[:longitude], ip_address: request.remote_ip)
      end
    end
    check_distance
    set_sessions_url
    if request.xhr?
      params["_"] = nil
      form_html = render_to_string(partial: 'courses/search_form')
      results_html = render_to_string(partial: 'courses/results')
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
      redirect_to school_edit_courses_path(@school)
    else
      render 'new'
    end
  end

  def show
		@course = @school.courses.find(params[:id])
    @sessions = @course.sessions
    @sessions = @sessions.group_by(&:semester_id)
	end

	def edit
		@course = @school.courses.find(params[:id])
  end

  def edit_index
    @edit = true
    index
    if !request.xhr?
      render 'index'
    end
  end

  def edit_sessions
    @edit = true
    sessions
    if !request.xhr?
      render 'sessions'
    end
  end

  def update
		@course = @school.courses.find(params[:id])
  	if @course.update_attributes(course_params)
      flash[:success] = "Course Updated!"
      redirect_to school_edit_courses_path(@school)
    else
      render 'edit'
    end
  end

  def destroy
		@course = Course.find(params[:id]).destroy
    flash[:success] = "Course deleted."
    redirect_to school_edit_courses_path(@school)
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

  def json
    if params[:course_id].present?
      session = nil
      course = Course.find(params[:course_id])
      html = render_to_string(partial: 'courses/dropdown_info', locals: { course: course, session: session })
    elsif params[:session_id].present?
      session = Session.find(params[:session_id])
      course = session.course
      html = render_to_string(partial: 'course_sessions/dropdown_info', locals: { course: course, session: session })
    end
    respond_to do |format|
      msg = { html: html }
      format.json  { render :json => msg }
    end
  end

  def get_results
    if params[:semester].present?
      sessions
      form_html = render_to_string(partial: 'course_sessions/search_form')
      results_html = render_to_string(partial: 'course_sessions/results')
    else
      index
      form_html = render_to_string(partial: 'courses/search_form')
      results_html = render_to_string(partial: 'courses/results')
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

    def set_sessions_url
      if params[:search].present?
        if @school.present?
          if @edit
            @sessions_path = school_edit_sessions_path(@school, search: params[:search]) 
          else 
            @sessions_path = school_sessions_path(@school, search: params[:search]) 
          end 
        else 
          @sessions_path = course_sessions_path(search: params[:search]) 
        end 
      else 
        if @school.present? 
          if @edit 
            @sessions_path = school_edit_sessions_path(@school)
          else 
            @sessions_path = school_sessions_path(@school) 
          end 
        else 
          @sessions_path = course_sessions_path 
        end 
      end 
    end

end
