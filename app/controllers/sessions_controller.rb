class SessionsController < ApplicationController

  protect_from_forgery except: :location

  def new
    @user = User.new
  end

  def create
    if Rails.env != 'production'
      user = User.find_by(email: params[:session][:email].downcase)
      if user && user.authenticate(params[:session][:password])
        sign_in user
        redirect_back_or account_path
      else
        flash.now[:error] = 'Invalid email/password combination'
        render 'new'
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  def location
    if params[:latitude].present? || params[:longitude]
      store_geolocation(params[:latitude], params[:longitude], params[:city], params[:state], params[:method])
      respond_to do |format|
        msg = { status: "ok", message: "Location saved!" }
        format.json  { render :json => msg }
      end
    end
  end
end
