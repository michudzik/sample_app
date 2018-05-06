class PasswordResetsController < ApplicationController
  before_action :get_user,          only: [:edit, :update]
  before_action :valid_user,        only: [:edit, :update]
  before_action :check_expiration,  only: [:edit, :update] # Case(1)

  def new

  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  # Case(1) - An expired password reset
  # Case(2) - A failed update due to an invalid password
  # Case(3) - A failed update (which initially looks as a successful one) due to an empty password and confirmation field.
  # Case(4) - A successful update

  def update
    if params[:user][:password].empty?        # Case(2)
      @user.errors.add(:password, "Cannot be empty")
      render 'edit'
    elsif @user.update_attributes(user_params) # Case(4)
      log_in @user
      flash[:success] = "Password has been reset"
      @user.update_attribute(:reset_digest, nil)
      redirect_to @user
    else                                      # Case(3)
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Before filters

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

  # Checks expiration date of reset token
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset token has expired"
      redirect_to new_password_reset_url
    end
  end

end
