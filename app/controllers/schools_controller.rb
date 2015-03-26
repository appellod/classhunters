class SchoolsController < ApplicationController
	before_action :signed_in_user, only: [:new, :create, :edit, :update, :destroy, :import]
	before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :admin_user, only: [:new, :create, :import]

	def index
    if params[:location].present?
      #geo = Geocoder.search(params[:location])
      #store_geolocation(geo[0].coordinates[0], geo[0].coordinates[1], geo[0].city, geo[0].state_code, 'geocoder')
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
    if params[:search].present?
      school = School.where(name: params[:search])
      if school.count > 0
        redirect_to school_path(school.first)
      else
        search = School.search do
          fulltext params[:search]
        end
        @schools = search.results
        @schools = @schools.paginate(page: params[:page])
      end
    end
    if params[:sort].nil? && params[:search].nil?
      @schools = School.where('name LIKE ?', "#{params[:page_alpha]}%").order(:name).paginate(page: params[:page])
    elsif params[:sort] != "map"
      @schools = @schools.paginate(page: params[:page])
    end
    if request.xhr?
      params["_"] = nil
      results_html = render_to_string(partial: 'results')
      respond_to do |format|
        msg = { results_html: results_html }
        format.json  { render :json => msg }
      end
    end
	end
	
	def new
		@school = School.new
	end

	def create
    @school = current_user.schools.build(school_params)
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
  	if @school.update_attributes(school_params)
      flash[:success] = "School Updated!"
      redirect_to @school
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

  private

    def school_params
      params.require(:school).permit(:name, :address, :website,
      	:latitude, :longitude)
    end

    # Before filters

    def correct_user
      @school = School.find(params[:id])
      redirect_to(root_url) unless (@school.users.exists?(current_user) || current_user.admin?)
    end
end
