class PasswordResetsController < ApplicationController
  before_action(:user, only: %i[edit update])
  before_action(:valid_user, only: %i[edit update])

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to(root_url)
    else
      flash.now[:danger] = 'Email address not found'
      render('new')
    end
  end

  private

  def user
    @user = User.find_by(email: params[:email])
  end

  # Confirm valid user
  def valid_user
    return if @user &&
              @user.activated? &&
              @user.authenticated?(:reset, params[:id])

    redirect_to(root_url)
  end
end
