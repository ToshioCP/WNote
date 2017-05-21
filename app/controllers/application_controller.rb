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

  def verify_user
    if ! (@user = current_user)
      flash[:warning] = I18n.t('Guest_not_have_access')
      redirect_back(fallback_location: root_path)
    end
  end

  def access_denied
    flash[:warnings] = I18n.t('access_denied_resource')
    redirect_to root_path
  end

end
