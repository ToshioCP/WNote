module UsersHelper
  def uh_current_user
    session[:current_user_id] && User.find_by(id: session[:current_user_id])
  end
  def login?
    uh_current_user ? true : false
  end
  def guest?
    !login?
  end

  def from_edit?
    @user.id
  end
  def from_new?
    !from_edit?
  end
end
