class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  def show
    @prev_note = @note.section.prev_note(@note)
    @next_note = @note.section.next_note(@note)
  end

  def new
    @note = Note.new
    @note.section_id = params[:section_id]
    @redirect_path = notes_path
  end

  def edit
    @redirect_path = note_path(@note)
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

  def update
    if @note.update(note_params)
      flash[:success] = 'Note was successfully updated.'
      redirect_to @note
    else
      render :edit
    end
  end

  def destroy
    section = @note.section
    @note.destroy
    flash[:success] = 'Note was successfully destroyed.'
    redirect_to section
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def note_params
      params.require(:note).permit(:section_id, :title, :text)
    end
end
