class SchoolsController < ApplicationController
  require 'open-uri'

	before_action :signed_in_user, only: [:new, :create, :edit, :update, :destroy, :import]
	before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :admin_user, only: [:new, :create, :import]

  include SchoolsHelper

	def index
    if params[:location].present?
      geo = Geocoder.search(params[:location])
      if geo.present?
        store_geolocation(geo[0].coordinates[0], geo[0].coordinates[1], geo[0].city, geo[0].state_code, 'geocoder')
      else
        flash.now[:warning] = "There was an error calculating your location. Please try again."
      end
    end
    if params[:user_id].present?
      @schools = current_user.schools.order(:name)
    else
      @schools = School.order(:name)
    end
    if params[:sort].present?
      if params[:sort] == "distance"
        if location_set?
          latitude = session[:latitude]
          longitude = session[:longitude]
          if params[:school_type].present?
            @schools = @schools.where(category: params[:school_type])
          end
          @schools = @schools.sort_by { |school| school.distance_from([latitude, longitude])}
        end
      elsif params[:sort] == "state"
        @schools = School.order(:state)
        if params[:state].present?
          @schools = School.where(state: params[:state]).order(:name)
        end
      elsif params[:sort] == "map"
        @schools = School.all
        if location_set?
          @min_lat = session[:latitude] - 0.1
          @min_lon = session[:longitude] - 0.1
          @max_lat = session[:latitude] + 0.1
          @max_lon = session[:longitude] + 0.1
        else
          lats = []
          lons = []
          @schools.each do |school|
            lats << school.latitude
            lons << school.longitude
          end
          @min_lat = lats.min
          @min_lon = lons.min
          @max_lat = lats.max
          @max_lon = lons.max
        end
      end
    end
    if params[:search].present? && !params[:sort].present?
      search = School.search_ids do
        fulltext params[:search]
      end
      @schools = School.where(id: search)
    end
    if params[:page_alpha].present?
      @schools = @schools.where('name LIKE ?', "#{params[:page_alpha]}%").order(:name).paginate(page: params[:page])
    end
    if params[:school_type].present? && params[:sort] != "distance"
      @schools = @schools.where(category: params[:school_type])
    end
    if params[:sort] != "map"
      @schools = @schools.paginate(page: params[:page])
    end
    if request.xhr?
      params["_"] = nil
      results_html = render_to_string(partial: 'results')
      form_html = render_to_string(partial: 'search_form')
      respond_to do |format|
        msg = { results_html: results_html, form_html: form_html }
        format.json  { render :json => msg }
      end
    end
	end
	
	def new
		@school = School.new
	end

	def create
    @school = current_user.schools.build
    @school = handle_form(@school)
    if @school.save
      flash[:success] = "School created!"
      redirect_to @school
    else
      render 'new'
    end
  end

  def show
  	@school = School.find(params[:id])
  end

  def edit
  end

  def update
    @school = handle_form(@school)
  	if @school.save
      flash[:success] = "School Updated!"
      redirect_to edit_school_path(@school)
    else
      render 'edit'
    end
  end

  def destroy
    @school.destroy
    flash[:success] = "School deleted."
    redirect_to schools_url
  end

  def import
    if params[:file].present?
      #begin
        file = params[:file]
        file.tempfile.binmode
        file.tempfile = Base64.encode64(file.tempfile.read)
        Resque.enqueue(SchoolImporter, file, params[:category])
        redirect_to schools_path, notice: "Schools are currently being imported."
      #rescue
      #  flash.now[:error] = "Wrong file format."
      #end
    end
  end

  def autocomplete
    if params[:term].present?
      schools = School.where('name LIKE :name', { name: "%#{params[:term]}%" })
      rows = []
      schools.each do |school|
        rows << school.name
      end
      respond_to do |format|
        format.json  { render json: rows }
      end
    end
  end

  def sync
    @school = School.find(params[:id])
    if request.post?
      @response = nil
      @results = nil
      begin
        @results = JSON.parse(open(params[:url]).read)
      rescue
        @results = open(params[:url]).read
      end
    end
  end

  private

    def school_params
      params.require(:school).permit(:name, :address, :website,
      	:latitude, :longitude, :phone)
    end

    # Before filters

    def correct_user
      @school = School.find(params[:id])
      redirect_to(root_url) unless (@school.users.exists?(current_user) || current_user.admin?)
    end

    def handle_form(school)
      school.name = params[:school][:name]
      school.description = params[:school][:description]
      school.address = params[:school][:address]
      school.category = school_categories.include?(params[:school][:category]) ? params[:school][:category] : ""
      school.website = params[:school][:website]
      school.founding_date = params[:school][:founding_date]
      for i in 0..2
        if params[:phone_names][i].present? && params[:phone_numbers][i].present?
          if params[:phone_ids][i].present?
            phone = school.phone_numbers.where(id: params[:phone_ids][i]).first
            phone.name = params[:phone_names][i]
            phone.number = params[:phone_numbers][i]
            phone.save
          else
            phone = school.phone_numbers.create(name: params[:phone_names][i], number: params[:phone_numbers][i])
          end
        elsif params[:phone_names][i].empty? && params[:phone_numbers][i].empty? && params[:phone_ids][i].present?
          PhoneNumber.find(params[:phone_ids][i]).delete
        end
        if params[:email_names][i].present? && params[:email_emails][i].present?
          if params[:email_ids][i].present?
            email = school.emails.where(id: params[:email_ids][i]).first
            email.name = params[:email_names][i]
            email.address = params[:email_emails][i]
            email.save
          else
            email = school.emails.create(name: params[:email_names][i], address: params[:email_emails][i])
          end
        elsif params[:email_names][i].empty? && params[:email_emails][i].empty? && params[:email_ids][i].present?
          Email.find(params[:email_ids][i]).delete
        end
        if params[:link_names][i].present? && params[:link_urls][i].present?
          if params[:link_ids][i].present?
            link = school.links.where(id: params[:link_ids][i]).first
          else
            link = school.links.build
          end
          link.name = params[:link_names][i]
          link.url = params[:link_urls][i]
          if !link.url.include?("https") && !link.url.include?("http")
            link.url = "http://#{link.url}"
          end
          link.save
        elsif params[:link_names][i].empty? && params[:link_urls][i].empty? && params[:link_ids][i].present?
          Link.find(params[:link_ids][i]).delete
        end
      end
      if school.school_style.present?
        style = school.school_style
      else
        style = school.build_school_style
      end
      style.foreground = params[:foreground][0].gsub!('#', '')
      style.background = params[:background][0].gsub!('#', '')
      style.save
      if current_user.admin
        school.start_date = Date.strptime(params[:school][:start_date], "%m/%d/%Y").strftime("%Y-%m-%d") if params[:school][:start_date].present?
        school.end_date = Date.strptime(params[:school][:end_date], "%m/%d/%Y").strftime("%Y-%m-%d") if params[:school][:end_date].present?
        school.active = params[:school][:active]
      end
      return school
    end
end
