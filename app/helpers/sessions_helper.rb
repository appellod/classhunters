module SessionsHelper
  # Signs a user in. Updates their remember_token field in database.
	def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.digest(remember_token))
    self.current_user = user
  end

  # Checks if a user is currently signed in
  # @return True if user is signed in, false otherwise.
  def signed_in?
    !current_user.nil?
  end

  # Changes the current user to the given user
  def current_user=(user)
    @current_user = user
  end

  # Gets the current user from cookie data. Finds user associated with
  # stored remember_token in database.
  # @return The current user
  def current_user
    remember_token = User.digest(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  # Checks if the current user is equivalent to the given user
  # @return True if current user is same as given user, false otherwise.
  def current_user?(user)
    user == current_user
  end

  # Redirects user to sign in page if they are trying to access member page.
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  # Signs a user out
  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.digest(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  # If there is a return_to URL stored in session data, redirect to that URL.
  # If there is no return_to URL, redirect to specified address.
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  # Stores the current URL as return_to in the session.
  def store_location
    session[:return_to] = request.url if request.get?
  end

  # Takes latitude and longitude and stores them as session variables.
  # @param latitude The latitude
  # @param longitude The longitude
  def store_geolocation(latitude, longitude, city, state, method)
    session[:latitude] = latitude.to_f
    session[:longitude] = longitude.to_f
    session[:location_name] = "#{city}, #{state}"
    session[:location_time] = Time.now
    session[:location_method] = method
  end

  # Redirects to the root url unless the current user is an admin.
  def admin_user
    (current_user.present? && current_user.admin?)
  end

  def get_location_by_ip
    require 'open-uri'
    if Rails.env == 'development'
      ip = open('http://whatismyip.akamai.com').read
    else
      ip = request.remote_ip
    end
    geo = Geocoder.search(ip)
    if geo.present? && geo[0].city.present? && geo[0].state_code.present?
      store_geolocation(geo[0].latitude, geo[0].longitude, geo[0].city, geo[0].state_code, 'ip')
    end
  end

  def location_set?
    return session[:latitude].present? && session[:longitude].present?
  end
end
