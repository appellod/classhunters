class SearchController < ApplicationController

  # Index function that searches ALL classes
  def index
    if params[:location].present?
      coords = Geocoder.coordinates(params[:location]);
      if coords.present?
        session[:latitude] = coords[0];
        session[:longitude] = coords[1];
      end
    end

    if !session[:latitude].nil? && !session[:longitude].nil?
      latitude = session[:latitude]
      longitude = session[:longitude]
      search = Course.search do
        fulltext params[:search]
      end
      @courses = search.results
      @courses = @courses.sort_by { |course| course.school.distance_from([latitude, longitude]) }
      @schools = Array.new
      @courses.each do |course|
        @schools << course.school unless @schools.include?(course.school)
      end
      @schools = @schools.paginate(page: params[:page])
      @courses = @courses.paginate(page: params[:page])
      Search.create(input: params[:search], remote_ip: request.remote_ip, page: request.referrer)
    end
    
  end
end