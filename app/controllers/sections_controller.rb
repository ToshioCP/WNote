class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :edit, :update, :destroy]

  def show
    @prev_section = @section.article.prev_section(@section)
    @next_section = @section.article.next_section(@section)
  end

  def new
    @section = Section.new
    @section.article_id = params[:article_id]
    @redirect_path = sections_path
  end

  def edit
    @redirect_path = section_path(@section) 
  end

  def create
    @section = Section.new(section_params)

    if @section.save
      flash[:success] = 'Section was successfully created.'
      redirect_to @section
    else
      render :new
    end
  end

  def update
    if @section.update(section_params)
      flash[:success] = 'Section was successfully updated.'
      redirect_to @section
    else
      render :edit
    end
  end

  def destroy
    article = @section.article
    @section.destroy
    flash[:success] = 'Section was successfully destroyed.'
    redirect_to article
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section
      @section = Section.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.require(:section).permit(:article_id, :heading, :note_order)
    end
end
