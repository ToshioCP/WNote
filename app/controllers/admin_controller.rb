class AdminController < ApplicationController
before_action :admin_check

  def list_users
    @users = User.all
  end

  def delete_user
    id = params[:id]
    if id.to_i == current_user.id then
      redirect_to root_path, flash: { warnings: "User can't delete (him/her)self)." }
    else
      User.find(id).destroy
      redirect_to root_path, flash: { success: 'User was successfully destroyed.' }
    end
  end

  private

    def admin_check
      if noadmin?
        flash[:warnings] = "You don't have access to this section."
        redirect_to root_path
      end
    end

end
