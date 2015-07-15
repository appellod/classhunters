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
    #crawler = Crawler.new
    #crawler.crawl_school(850)
    #Crawler.crawl_schools
    #@results = Crawler.crawl_for_webadvisor
    #@results = School.where(id: [1653, 1654, 1655, 1656, 1657, 1658, 1663, 1666, 1778, 1780, 1782, 1784, 1787, 1789, 1790, 1795, 1798, 1799, 1800, 1801, 1802, 1803, 1804, 1810, 1814, 1818, 1820, 1822, 1827, 1834, 1837, 1838, 2009, 2014, 2017, 2081, 2083, 2086, 2087, 2088, 2089, 2093, 2095, 2099, 2102, 2104, 2107, 2109, 2110, 2112, 2113, 2115, 2116, 2117, 2118, 2119, 2120, 2121, 2157, 2377, 2378, 2462, 2464, 2465, 2466, 2467, 2468, 2469, 2470, 2471, 2472, 2474, 2475, 2477, 2478, 2479, 2480, 2481, 2482, 2533, 2534, 2535, 2537, 2538, 2567, 2568, 2569, 2570, 2572, 2573, 2574, 2575, 2576, 2577, 2578, 2579, 2580, 2581, 2582, 2583, 2584, 2585, 2586, 2587, 2588, 2589, 2590, 2591, 2592, 2593, 2594, 2595, 2596, 2597, 2598, 2681, 2682, 2684, 2685, 2686, 2687, 2688, 2690, 2691, 2692, 2693, 2694, 2695, 2696, 2697, 2739, 2799, 2800, 2801, 2802, 2818, 2819, 2821, 2822, 2823, 2824, 2825, 2826, 2827, 2828, 2830, 2831, 2832, 2833, 2834, 2835, 2836, 2837, 2838, 2839, 2840, 2841, 2842, 2843, 2844, 2845, 2846, 2847, 2848, 2849, 2850, 2851, 2852, 2853, 2854, 2855, 2856, 2857, 2858, 2859, 2865, 2866, 2867, 2868, 2875, 2876, 2877, 2878, 2879, 2880, 2881, 2882, 2883, 2889, 2890, 2891, 2892, 2908, 2909, 2910, 2911, 2912, 2913, 2914, 2915, 2916, 2917, 2918, 2919, 2920, 2921, 3046, 3047, 3048, 3049, 3050, 3051, 3052, 3053, 3054, 3055, 3056, 3057, 3058, 3059, 3060, 3061, 3062, 3064, 3065, 3066, 3068, 3069, 3070, 3071, 3072, 3073, 3074, 3075, 3076, 3193, 3194, 3195, 3196, 3197, 3198, 3199, 3200, 3201, 3202, 3203, 3204, 3205, 3206, 3207, 3209, 3210, 3211, 3212, 3213, 3214, 3215, 3216, 3217, 3218, 3219, 3220, 3347, 3348, 3349, 3350, 3351, 3352, 3354, 3355, 3356, 3357, 3358, 3359, 3360, 3361, 3362, 3363, 3364]).pluck(:name);
    #@results = ""
    #pc = PortalCrawler.new
    #pc.crawl
    Crawler.find_schools
    #crawler = Crawler.new
    #crawler.initialize_session
    #@results = crawler.crawl_for_urls(851)
  end

  private

    def contact_params
      params.require(:contact).permit(:name, :email, :school, :message)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
