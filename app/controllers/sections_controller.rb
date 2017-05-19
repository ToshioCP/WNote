class SectionsController < ApplicationController
  before_action :set_models_variable
  before_action :verify_correct_user, only: [:new, :create, :destroy]
  before_action only: [:edit, :update] do
    verify_correct_user if @article.w_public == 0
  end
  before_action only: :show do
    verify_correct_user if @article.r_public == 0
  end

  def new
    @section = @article.sections.build
  end

  def create
    @section = Section.new(section_params)
    if @section.save
      flash[:success] = I18n.t('x_created', x: I18n.t('Section'))
      redirect_to @section
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @section.update(section_params)
      flash[:success] = I18n.t('x_updated', x: I18n.t('Section'))
      redirect_to @section
    else
      render :edit
    end
  end

  def show
    @prev_section = @article.prev_section(@section)
    @next_section = @article.next_section(@section)
  end

  def destroy
    @section.destroy
    flash[:success] = I18n.t('x_destroyed', x: I18n.t('Section'))
    redirect_to @article
  end

  private
    def set_models_variable
      if params[:id] # edit, update, show, destroy
        @section = Section.find(params[:id]) if params[:id]
        @article = @section.article
      else
        @article = Article.find(params[:article_id]) if params[:article_id] # new
        @article = Article.find(params[:section][:article_id]) if params[:section] && params[:section][:article_id] # create
      end
      @user = @article.user
      if ! @user
        flash[:warning] = I18n.t('section_or_article_not_being_read')
        redirect_back(fallback_location: root_path)
      end
    end
    def section_params
      params.require(:section).permit(:article_id, :heading, :note_order)
    end

end
