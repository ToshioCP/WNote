class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include UsersHelper

  def verify_correct_user
    if ! (current_user && current_user == @user)
      flash[:warning] = "Only the owner is allowed to access to this section."
      redirect_back(fallback_location: root_path)
    end
  end

end
