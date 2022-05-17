class AdminController < ApplicationController
before_action :verify_admin

  def list_users
    @users = User.all
  end

  def delete_user
    @user = User.find(params[:id]) # @user is Not current_user !!
    if @user.admin then
      redirect_to root_path, status: :see_other, flash: { warnings: I18n.t('can_not_delete_admin') }
    else
      @user.destroy
      redirect_to root_path, status: :see_other, flash: { success: I18n.t('user_destroyed') }
    end
  end

  private

    def verify_admin
      if (! current_user) || (! current_user.admin)
        flash[:warnings] = I18n.t('access_denied_resource')
        redirect_to root_path
      end
    end

end
