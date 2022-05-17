require 'securerandom'
require 'rmagick'
require 'base64'

class ArticlesController < ApplicationController

  include ImagesHelper

  before_action :set_models_variable, except: [:index, :new, :create]
  before_action :verify_user, except: [:index, :show]
# verify_user checked login.
  before_action only: [:edit, :update] do
    access_denied if ! edit_permission? @article
  end
  before_action only: :destroy do
    access_denied if ! destroy_permission? @article
  end
  before_action only: :show do
    access_denied if ! read_permission? @article
  end

  def index
    @articles = Article.all
    articles = []
    @articles.each do |article|
      if read_permission? article
        articles << article
      end
    end
    @articles = articles
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    @article.user_id = @user.id
    if @article.save
      redirect_to @article, flash: { success: I18n.t('x_created', x: I18n.t('Article'))}
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, flash: { success: I18n.t('x_updated', x: I18n.t('Article')) }
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @article.destroy
    redirect_to articles_path, status: :see_other, flash: { success: I18n.t('x_destroyed', x: I18n.t('Article')) }
  end

  private
    def set_models_variable
      @article = Article.find(params[:id]) if params[:id]
      if ! @article # params[:id]が無かったか、Article.find(params[:id])で見つからなかった場合
        flash[:warning] = t('Article_missing')
        redirect_back(fallback_location: root_path)
      end
    end
    # Strong parameter, only allow the white list through.
    # Auto generate uuid
    # If jpeg file is uploaded, add {:cover_image => file_data} to parameter
    # and make thumbnail
    def article_params
      ap = params.require(:article).permit(:title, :author, :language, :modified_datetime, :identifier_uuid,\
                                           :cover_image, :css, :r_public, :w_public, :section_order)
      if ap[:identifier_uuid] == ''
        ap[:identifier_uuid] = SecureRandom.uuid
      end
      uploaded_io = params[:article][:cover_image]
      if uploaded_io
        ap[:cover_image] = uploaded_io.read
        img = Magick::ImageList.new.from_blob(ap[:cover_image]).first
        ap[:icon_base64] = Base64.encode64(img.thumbnail(32,32).to_blob)
      end
      return ap
    end

end
