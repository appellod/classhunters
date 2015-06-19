class SiteController < ApplicationController
  require 'capybara/dsl'
  require 'capybara-webkit'

  include ApplicationHelper
  protect_from_forgery except: :edit_user
  layout "application", only: [:stats]

  def home
  	@contact = Contact.new
    if mobile?
      render 'home_mobile'
    end
  end

  def account
    @user = current_user
    if current_user.admin?
      @schools = School.all.order(:name).paginate(page: params[:page])
    else
      @schools = @user.schools.paginate(page: params[:page])
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

  def edit_user
    @user = current_user
    if @user.update_attributes(user_params)
      flash.now[:success] = "Your account information has been updated successfully!"
      params[:view] = "account"
    else
      params[:view] = "edit_account"
    end
    params["_"] = nil
    results_html = render_to_string(partial: 'results')
    respond_to do |format|
      msg = { results_html: results_html }
      format.json  { render :json => msg }
    end
  end

  def about
  end

  def contact
    if request.post?
      @contact = Contact.new(contact_params)
      if @contact.save
        flash[:success] = "Contact information submitted! Thank you for expressing interest in Classhunters."
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

  def test
    crawler = Crawler.new
    @results = crawler.crawl(School.find(3046))
  end

  private

    def contact_params
      params.require(:contact).permit(:name, :email, :school, :message)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
