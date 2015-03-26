class SiteController < ApplicationController
  include ApplicationHelper

  def home
  	@contact = Contact.new
    if mobile?
      render 'home_mobile'
    end
  end

  def about
  end

  def contact
    if request.post?
      @contact = Contact.new(contact_params)
      if @contact.save
        flash[:notice] = "Contact information submitted! Thank you for expressing interest in Classhunters."
        Mailer.contact_email(@contact.name, @contact.email, @contact.school, @contact.message).deliver
        redirect_to contact_url
      else
        render 'contact'
      end
    else
      @contact = Contact.new
    end
  end

  def autocomplete
    rows = []
    if params[:school].present?
      schools = School.where('name LIKE :name', { name: "%#{params[:school]}%" })
      schools.each do |school|
        rows << school.name
      end
    end
    if params[:location].present?
      @cities = City.where('zip LIKE :zip OR state LIKE :state OR city LIKE :city', { zip: "%#{params[:location]}%", state: "#{params[:location]}", city: "#{params[:location]}%" }).order(:state)
      @cities.each do |city|
        str = "#{city.city}, #{city.state}"
        rows << str unless rows.include? str
      end
    end
    respond_to do |format|
      format.json  { render json: rows }
    end
  end

  def stats
    if admin_user
      @course_searches = CourseSearch.select("search, count(*) AS count").where("search IS NOT NULL").group("search").order("count(*) DESC").limit(20)
      @session_searches = SessionSearch.select("search, count(*) AS count").where("search IS NOT NULL").group("search").order("count(*) DESC").limit(20)
      @course_search_locations = CourseSearch.select(:latitude, :longitude)
      @session_search_locations = SessionSearch.select(:latitude, :longitude)
    else
      redirect_to root_path
    end
  end

  private

    def contact_params
      params.require(:contact).permit(:name, :email,
        :school, :message)
    end
end
