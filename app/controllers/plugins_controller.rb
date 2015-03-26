class PluginsController < ApplicationController

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
          paginate per_page: 9999999
        end
        @courses_query = search.results
        @course_count = @courses_query.count
        @courses = @courses_query.group_by { |course| course.school }
        @courses = @courses.sort_by { |school, courses| school.distance_from([latitude, longitude]) }
      end
    end
end
