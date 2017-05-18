class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include UsersHelper

  before_action :set_locale
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def verify_correct_user
    if ! (current_user && current_user == @user)
      flash[:warning] = I18n.t('only_owner')
      redirect_back(fallback_location: root_path)
    end
  end

end
