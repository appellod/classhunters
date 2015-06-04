class UsersController < ApplicationController
	before_action :signed_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user,   only: [:show, :edit, :update]
  before_action :admin_user,     only: [:index, :destroy]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    if current_user.admin?
      @schools = School.all.order(:name).paginate(page: params[:school_page])
    else
      @schools = @user.schools
    end
    if request.xhr?
      params["_"] = nil
      results_html = render_to_string(partial: 'schools')
      respond_to do |format|
        msg = { results_html: results_html }
        format.json  { render :json => msg }
      end
    end
  end

  def new
  	@user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome!"
      redirect_to user_path(@user)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def reset_password
    if request.post?
      if params[:hash].present?
        @user = User.where(email: params[:email]).first
        if @user.present?
          if params[:hash] == @user.reset_password_hash
            if params[:password].present? && params[:password_confirmation].present? && params[:password] == params[:password_confirmation]
              if @user.update(password: params[:password], password_confirmation: params[:password_confirmation], reset_password_hash: nil)
                flash.now[:success] = "Your new password has been set! You may now login with your new password."
              end
            else
              flash.now[:error] = "The password and confirmation fields do not match."
            end
          else
            flash.now[:error] = "The hash for a password reset associated with the given email address is incorrect."
          end
        else
          flash.now[:error] = "The given email address does not have an account associated with Classhunters."
        end
      else
        @user = User.where(email: params[:email]).first
        if @user.present?
          @user.reset_password_hash = SecureRandom.hex
          if @user.save
            flash.now[:success] = "A verification email has been sent to you."
            Mailer.reset_password_email(@user.email, @user.reset_password_hash).deliver
          end
        else
          flash.now[:error] = "The given email address does not have an account associated with Classhunters."
        end
      end
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Before filters

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    end
end
