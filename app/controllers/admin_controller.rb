class AdminController < ApplicationController
before_action :admin_check

  def list_users
    @users = User.all
  end

  def delete_user
    id = params[:id]
    if id.to_i == current_user.id then
      redirect_to root_path, flash: { warnings: I18n.t('can_not_delete_self') }
    else
      User.find(id).destroy
      redirect_to root_path, flash: { success: I18n.t('user_destroyed') }
    end
  end

  private

    def admin_check
      if noadmin?
        flash[:warnings] = I18n.t('access_denied_resource')
        redirect_to root_path
      end
    end

end
