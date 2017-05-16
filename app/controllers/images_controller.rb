class ImagesController < ApplicationController
  before_action :set_user
  before_action except: [:index, :new, :create] do
    @image = Image.find(params[:id])
  end

  def index
    @images = @user.images
  end

  def new
    @image = @user.images.build
    @method = "post"
    @path = "/images"
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      flash[:success] = 'Image was successfully created.'
      redirect_to images_path
    else
      render :new
    end
  end

  def edit
    @image.name.gsub!(/\A\d*_/,'')
    @method = "patch"
    @path = image_path(@image)
  end

  def update
    if @image.update(image_params)
      flash[:success] = 'Note was successfully updated.'
      redirect_to images_path
    else
      render :edit
    end
  end

  def destroy
    @image.destroy
    flash[:success] = 'Note was successfully destroyed.'
    redirect_to images_path
  end

  private
# set instance variable and check current user
    def set_user
      if ! (@user = current_user)
        flash[:error] = "You don't have access to this section."
        redirect_to root_path
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
