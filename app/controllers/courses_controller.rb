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
      @courses = @school.courses.order(:name)
    else
      @courses = Course.order(:name)
    end
    @departments = @courses.pluck(:department).uniq.sort
    if params[:departments].present?
      @courses = @courses.where(department: params[:departments])
    end
    if params[:search].present?
      @courses = @courses.where(['name LIKE ?', "%#{params[:search]}%"])
    end
    @courses = @courses.paginate(page: params[:page])
    params[:sort] ||= 'name'
	end

  def sessions
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @courses = current_user.courses.order(:name)
    elsif params[:school_id].present?
      @school = School.find(params[:school_id])
      @courses = @school.courses.order(:name)
    else
      @courses = Course.order(:name)
    end
    if @courses.count > 0
      if params[:semester].present?
        @sessions = Session.includes(:course).where(semester: params[:semester], course_id: @courses.pluck(:id)).order('courses.name')
      else
        i = 0
        while @sessions.nil? || @sessions.count == 0
          @sessions = Session.includes(:course).where(semester: semesters[i], course_id: @courses.pluck(:id)).order('courses.name')
          params[:semester] = semesters[i]
          i+=1
        end
      end
      if params[:search].present?
        @sessions = @sessions.where(['courses.name LIKE ?', "%#{params[:search]}%"])
      end
      if params[:days].present?
        days = ""
        params[:days].each_with_index do |day, i|
          if Session.column_names.include?(day)
            days << "#{day} = 1"
            if i < params[:days].count - 1
              days << " OR "
            end
          end
        end
        @sessions = @sessions.where(days)
      end
      if params[:departments].present?
        @sessions = @sessions.where(['courses.department IN (?)', params[:departments]])
      end
    end
    @departments = @courses.pluck(:department).uniq.sort
    @courses = @courses.paginate(page: params[:page])
    @sessions = @sessions.paginate(page: params[:page])
    params[:sort] ||= 'name'
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
      Resque.enqueue(CourseImporter, file, @school.id, params[:semester])
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
end
