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

  def read_permission?(article)
    if article.r_public?
      return true
    elsif guest?
      return false
    elsif article.user == current_user # "log in" is already checked by guest?
      return true
    elsif current_user.admin
      return true
    else #user, but not owner or admin.
      return false
    end
  end

  def edit_permission?(article)
    if guest? # guest can not write anything.
      return false
    elsif article.w_public?
      return true
    elsif article.user == current_user
      return true
    else #user, but not owner. Remark! admin doesn't have permission to edit an article of others.
      return false
    end
  end

  def destroy_permission?(article)
    if guest?
      return false
    elsif article.w_public?
      return true
    elsif article.user == current_user
      return true
    elsif current_user.admin # admin can delete any article.
      return true
    else
      return false
    end
  end

end
