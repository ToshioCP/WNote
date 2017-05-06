class SectionsController < ApplicationController
  before_action :login_check_and_set_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_section, only: [:show, :edit, :update, :destroy]
  before_action only: [:edit, :update] do
    if @article.w_public == 0
      check_correct_user
    end
  end
  before_action :check_correct_user, only: :destroy

  def show
    if @article.r_public == 0
        check_correct_user
    end
    @prev_section = @article.prev_section(@section)
    @next_section = @article.next_section(@section)
  end

  def new
    @article = Article.find(params[:article_id])
    @section = @article.sections.build
    @redirect_path = sections_path
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

  def edit
    @redirect_path = section_path(@section) 
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
    @section.destroy
    flash[:success] = 'Section was successfully destroyed.'
    redirect_to @article
  end

  private
    def login_check_and_set_user
      if (@user = current_user) == nil
        flash[:warning] = "You don't have access to this section."
        redirect_to root_path
      end
    end
    def set_section
      @section = Section.find(params[:id])
      @article = @section.article
    end
    def section_params
      params.require(:section).permit(:article_id, :heading, :note_order)
    end
    def check_correct_user
      if (@user = current_user) != @article.user
        flash[:warning] = "Only article's owner is allowed to access to this section."
        redirect_to root_path
      end
    end

end
