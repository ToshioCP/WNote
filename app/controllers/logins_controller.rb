class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:current_user_id] = user.id
      flash[:success] = "You have successfully logged in."
      redirect_to controller: :users, action: :show
    else
      render :new
    end
  end

  def destroy
    @_current_user = session[:current_user_id] = nil
    flash[:success] = "You have successfully logged out."
    redirect_to root_url
  end
end
