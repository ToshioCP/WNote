class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  def show
    @previous_note = Note.where("section_id = ? AND id < ?", @note.section.id, @note.id).last
    @next_note = Note.where("section_id = ? AND id > ?", @note.section.id, @note.id).first
  end

  def new
    @note = Note.new
    @note.section= Section.find(params[:section_id])
    @redirect_path = section_notes_path(@note.section)
  end

  def edit
    @redirect_path = note_path(@note)
  end

  def create
    @note = Note.new(note_params)
    @note.section= Section.find(params[:section_id])

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
      params.require(:note).permit(:title, :text)
    end
end
