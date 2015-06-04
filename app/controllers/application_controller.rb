class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  has_mobile_fu false

  before_action :get_location
  before_action :page_to_integer

  private

  	def get_location
  		if session[:latitude].nil? || session[:longitude].nil?
  			get_location_by_ip
  		end
  	end

    def page_to_integer
      params[:page] = params[:page].to_i if params[:page].present?
    end
end
