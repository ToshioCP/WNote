class SectionsController < ApplicationController
  before_action :set_section_variable, except: [:new, :create]
  before_action :set_models_variable
  before_action :verify_user, only: [:new, :create]
  before_action only: [:new, :create, :edit, :update] do
    access_denied if ! edit_permission? @article
  end
  before_action only: :destroy do
    access_denied if ! destroy_permission? @article
  end
  before_action only: :show do
    access_denied if ! read_permission? @article
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
    redirect_to @article, status: :see_other
  end

  private
    def set_section_variable
      @section = Section.find(params[:id]) if params[:id]
      if ! @section # params[:id]が無かったか、Section.find(params[:id])で見つからなかった場合
        flash[:warning] = I18n.t('Section_missing')
        redirect_back(fallback_location: root_path)
      end
    end
    def set_models_variable
      @article = @section.article if @section
      @article = Article.find(params[:article_id]) if params[:article_id] # new
      @article = Article.find(params[:section][:article_id]) if params[:section] && params[:section][:article_id] # create
      if ! @article
        flash[:warning] = I18n.t('Article_missing')
        redirect_back(fallback_location: root_path)
      end
    end
    def section_params
      params.require(:section).permit(:article_id, :heading, :note_order)
    end

end
