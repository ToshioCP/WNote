class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:current_user_id] = user.id
      flash[:success] = I18n.t('log_in_success')
      redirect_to user_path
    elsif user == nil
      flash[:warning] = I18n.t('User_not_found')
      redirect_to new_user_path
    else
      flash.now[:warning] = I18n.t('password_incorrect')
      render :new, status: :unauthorized
    end
  end

  def destroy
    logoff
    flash[:success] = I18n.t('log_out_success')
    redirect_to root_path, status: :see_other
  end
end
