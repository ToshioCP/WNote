class ImagesController < ApplicationController
  before_action :verify_user
  before_action :set_models_variable, except: [:index, :new, :create]

  def index
    @images = @user.images
  end

  def new
    @image = @user.images.build
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      flash[:success] = I18n.t('x_created', x: I18n.t('Image'))
      redirect_to images_path
    else
      render :new
    end
  end

  def edit
    @image.name.gsub!(/\A\d*_/,'')
  end

  def update
    if @image.update(image_params)
      flash[:success] = I18n.t('x_updated', x: I18n.t('Image'))
      redirect_to images_path
    else
      render :edit
    end
  end

  def destroy
    @image.destroy
    flash[:success] = I18n.t('x_destroyed', x: I18n.t('Image'))
    redirect_to images_path, status: :see_other
  end

  private
    def set_models_variable
      @image = Image.find(params[:id])
      if ! @image # params[:id]が無かったか、Image.find(params[:id])で見つからなかった場合
        flash[:warning] = t('Image_missing')
        redirect_back(fallback_location: root_path)
      end
    end
    def image_params
      ip = params.require(:image).permit(:name, :image)
# user_id はparamsにはない。だからpermitの引数に入れても意味がない。
# @userが必要なので、このメソッドを呼ぶ前にset_userメソッドを呼んでいなければならない
      ip[:user_id] = @user.id
      ip[:name] = "#{@user.id}_#{ip[:name]}" if ip[:name]
      uploaded_io = ip[:image]
      if uploaded_io
        ip[:image] = uploaded_io.read
      end
      return ip
    end

end
