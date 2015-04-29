class ArticlesController < ApplicationController
  before_action :login_check_and_set_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action only: [:edit, :update] do
    if @article.w_public == 0
      check_correct_user
    end
  end
  before_action :check_correct_user, only: :destroy

  def index
    @articles = Article.all
    articles = []
    @articles.each do |article|
      if article.r_public > 0 || (login? && article.user == current_user)
        articles << article
      end
    end
    @articles = articles
  end

  def show
    if @article.r_public == 0
        check_correct_user
    end
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(article_params)
    @article.user_id = @user.id
    if @article.save
      redirect_to @article, flash: { success: 'Article was successfully created.'}
    else
      render :new
    end
  end

  def update
    if @article.update(article_params)
      redirect_to @article, flash: { success: 'Article was successfully updated.' }
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, flash: { success: 'Article was successfully destroyed.' }
  end

  private
    def login_check_and_set_user
      if (@user = current_user) == nil
        flash[:error] = "You don't have access to this section."
        redirect_to :back
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:title, :author, :date, :section_order, :r_public, :w_public)
    end
    def check_correct_user
      if (@user = current_user) != @article.user
        flash[:warnings] = "Only article's owner is allowed to access to this section."
        redirect_to :back
      end
    end
end
