class ImagesController < ApplicationController
  before_action :set_instance_variable
  before_action except: [:index, :new, :create] do
    @image = Image.find(params[:id])
  end

  def index
    @images = @note.images
  end

  def new
    @image = @note.images.build
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      flash[:success] = 'Image was successfully created.'
      redirect_to note_images_path(@note)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @image.update(image_params)
      flash[:success] = 'Note was successfully updated.'
      redirect_to note_images_path(@note)
    else
      render :edit
    end
  end

  def destroy
    @image.destroy
    flash[:success] = 'Note was successfully destroyed.'
    redirect_to note_images_path(@note)
  end

  private
# set instance variable and check current user
    def set_instance_variable
      @note = Note.find(params[:note_id])
      @section = @note.section
      @article = @section.article
      @user = @article.user
      @current_user = current_user
      if (@current_user == nil) || (@current_user != @user)
        flash[:error] = "You don't have access to this section."
        redirect_to root_path
      end
    end
    def image_params
      ip = params.require(:image).permit(:name, :image)
# note_id はparamsの直下にあって、imageの下ではない。だからpermitの引数に入れても意味がない。
      ip[:note_id] = params[:note_id]
      uploaded_io = ip[:image]
      if uploaded_io
        ip[:image] = uploaded_io.read
      end
      return ip
    end

end
