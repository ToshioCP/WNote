module UsersHelper
  def current_user
    @_current_user ||= ( session[:current_user_id] && User.find_by(id: session[:current_user_id]) )
  end
  def login?
    current_user ? true : false
  end
  def guest?
    !login?
  end
  def admin?
    (user = current_user) && user.admin
  end
  def noadmin?
    admin? ? false : true
  end
  def logoff
    session[:current_user_id] = nil
  end

  def from_edit?
    @user.id
  end
  def from_new?
    !from_edit?
  end
end
