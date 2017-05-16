class NotesController < ApplicationController
  before_action :set_models_variable
  before_action :verify_correct_user, only: [:new, :create, :destroy]
  before_action only: [:edit, :update] do
    verify_correct_user if @article.w_public == 0
  end
  before_action only: :show do
    verify_correct_user if @article.r_public == 0
  end

  def new
    @note = @section.notes.build
    @path = notes_path
    @method = 'post'
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
    @path = notes_path(@note)
    @method = 'patch'
  end

  def update
    if @note.update(note_params)
      flash[:success] = 'Note was successfully updated.'
      redirect_to @note
    else
      render :edit
    end
  end

  def show
    @prev_note = @section.prev_note(@note)
    @next_note = @section.next_note(@note)
  end

  def destroy
    @note.destroy
    flash[:success] = 'Note was successfully destroyed.'
    redirect_to @section
  end

  private
    def set_models_variable
      @note = Note.find(params[:id]) if params[:id] # edit, update, show, destroy
      @section = @note.section if @note
      @section = Section.find(params[:section_id]) if params[:section_id] # new
      @section = Section.find(params[:note][:section_id]) if params[:note] && params[:note][:section_id] # create
      @article = @section.article if @section
      @user = @article.user if @article
      if ! @user
        flash[:warning] = "The note or the section couldn't read from the database."
        redirect_back(fallback_location: root_path)
      end
    end
    def note_params
      params.require(:note).permit(:section_id, :title, :text)
    end

end
