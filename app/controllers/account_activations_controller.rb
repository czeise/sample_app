class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # Activate the user
      activate(user)
    else
      # Handle invalid link
      flash[:danger] = 'Invalid activation link'
      redirect_to(root_url)
    end
  end

  private

  def activate(user)
    user.update_attribute(:activated, true)
    user.update_attribute(:activated_at, Time.zone.now)
    log_in(user)
    flash[:success] = 'Account activated!'
    redirect_to(user)
  end
end
