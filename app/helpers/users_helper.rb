module UsersHelper
  def current_user
    @current_user ||= ( session[:current_user_id] && User.find_by(id: session[:current_user_id]) )
  end
  def login?
    current_user ? true : false
  end
  def guest?
    !login?
  end
  def admin?
    login? && current_user.admin
  end
  def noadmin?
    admin? ? false : true
  end
  def logoff
    session[:current_user_id] = nil
  end
end
