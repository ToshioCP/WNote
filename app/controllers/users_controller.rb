class UsersController < ApplicationController
  before_action :login_check_and_set_user, only: [:show, :edit, :update, :destroy, :backup, :upload, :restore, :reset]

  def show
  end

  def new
    @user= User.new
  end

  def create
    @user = User.new(user_params)
    @user.admin = false
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
      flash.now[:warning] = 'Password was incorrect.'
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
      flash.now[:warning] = 'Password was incorrect.'
      render :destroy
      end
    else
      redirect_to '/users', flash: { warning: 'The owner is the only person who can delete his/her account.' } 
    end
  end

  def backup
    articles = []
    @user.articles.each do |article|
      sections = []
      article.ordered_sections.each do |section|
        notes = []
        section.ordered_notes.each do |note|
          notes << note
        end
        sections << [section,notes]
      end
      articles << [article, sections]
    end
    backup_json_data = articles.to_json
    send_data backup_json_data, filename: "#{@user.name}.json", type: "application/json"
  end

  def upload
  end

  def restore
    uploaded_io = params[:restore_data]
#    original_filename = uploaded_io.original_filename
#    content_type = uploaded_io.content_type
    articles = ActiveSupport::JSON.decode(uploaded_io.read)
    articles.each do |a|
      article, sections = a
      @article = @user.articles.create(title: article['title'], author: article['author'], date: article['date'],
        w_public: article['w_public'], r_public: article['r_public'])
      sections.each do |s|
        section, notes = s
        @section = @article.sections.create(heading: section['heading'])
        notes.each do |note|
          @section.notes.create(title: note['title'], text: note['text'])
        end
      end
    end
    redirect_to '/users', flash: { success: 'Backup data was successfully restored.' } 
  end

  def reset
    @user.articles.destroy_all
    redirect_to '/users', flash: { success: 'All articles was successfully destroyed.' } 
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
