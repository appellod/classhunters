class CoursesController < ApplicationController
  require 'csv'
  
  before_action :get_school, except: [:index, :add_to_user, :remove_from_user, :saved]
	before_action :signed_in_user, only: [:new, :create, :edit, :update, :destroy]
	before_action :correct_user, only: [:import, :edit, :update, :destroy]

	def index
    if params[:user_id].present?
      @user = User.find(params[:user_id])
		  @courses = current_user.courses.order(:name).paginate(page: params[:page])
    elsif params[:school_id].present?
      @school = School.find(params[:school_id])
      @courses = School.find(params[:school_id]).courses.order(:name).paginate(page: params[:page])
    else
      @courses = Course.order(:name).paginate(page: params[:page])
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
      Resque.enqueue(CourseImporter, file, @school.id)
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
