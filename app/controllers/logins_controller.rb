class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:current_user_id] = user.id
      flash[:success] = I18n.t('log_in_success')
      redirect_to user_path
    else
      render :new
    end
  end

  def destroy
    logoff
    flash[:success] = I18n.t('log_out_success')
    redirect_to root_path
  end
end
