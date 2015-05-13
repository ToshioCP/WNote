class NotesController < ApplicationController
  before_action :login_check_and_set_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_note, only: [:show, :edit, :update, :destroy]
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
    @prev_note = @section.prev_note(@note)
    @next_note = @section.next_note(@note)
  end

  def new
    @section = Section.find(params[:section_id])
    @note = @section.notes.build
    @article = @section.article
    @redirect_path = notes_path
  end

  def create
    @note = Note.new(note_params)
    if @note.save
      flash[:success] = 'Note was successfully created.'
      redirect_to @note
    else
      render :new
    end
  end

  def edit
    @redirect_path = note_path(@note)
  end

  def update
    if @note.update(note_params)
      flash[:success] = 'Note was successfully updated.'
      redirect_to @note
    else
      render :edit
    end
  end

  def destroy
    @note.destroy
    flash[:success] = 'Note was successfully destroyed.'
    redirect_to @section
  end

  private
    def login_check_and_set_user
      if (@user = current_user) == nil
        flash[:error] = "You don't have access to this section."
        redirect_to :back
      end
    end
    def set_note
      @note = Note.find(params[:id])
      @section = @note.section
      @article = @section.article
    end
    def note_params
      params.require(:note).permit(:section_id, :title, :text)
    end
    def check_correct_user
      if (@user = current_user) != @article.user
        flash[:warning] = "Only article's owner is allowed to access to this section."
        redirect_to :back
      end
    end

end
