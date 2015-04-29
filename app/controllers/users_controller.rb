class UsersController < ApplicationController
  before_action :login_check_and_set_user, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @user= User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:current_user_id] = @user.id
      flash[:success] = 'Welcome to WNote !!'
      redirect_to action: :show
    else
      render :new
    end
  end

  def edit
  end

  def update
    if !@user.authenticate(params[:current_password])
      flash.now[:warnings] = 'Password was incorrect.'
      render :edit
      return
    end
    if @user.update(update_params)
      flash[:success] = 'User was successfully updated.'
      redirect_to '/users'
    else
      render :edit
    end
  end

  def destroy
    if request.delete?
      render :destroy
    elsif request.post?
      if @user.authenticate(user_params[:password])
        @user.destroy
        logoff
        redirect_to root_url, flash: { success: 'User was successfully destroyed.' }
      else
      flash.now[:warnings] = 'Password was incorrect.'
      render :destroy
      end
    else
      redirect_to '/users', flash: { warnings: 'The owner is the only person who can delete his/her account.' } 
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def login_check_and_set_user
      if (@user = current_user) == nil
        flash[:error] = "You don't have access to this section."
        redirect_to :back
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation )
    end

    def update_params
      user_params.reject {|key,value| value.nil? || value == ''}
    end
end
