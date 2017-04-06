class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        # Log the user in and redirect to the user's show page
        normal_login(@user)
      else
        invalid_activation
      end
    else
      invalid_login
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to(root_url)
  end

  private

  def normal_login(user)
    log_in(user)

    params[:session][:remember_me] == '1' ? remember(user) : forget(user)

    redirect_back_or(user)
  end

  def invalid_activation
    flash[:warning] =
      'Account not activated. Check your email for the activation link.'
    redirect_to(root_url)
  end

  def invalid_login
    flash.now[:danger] = 'Invalid email/password combination'
    render('new')
  end
end
