class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  # GET /notes
  def index
    @notes = Note.all
  end

  # GET /notes/1
  def show
  end

  # GET /notes/new
  def new
    @note = Note.new
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  def create
    @note = Note.new(note_params)

    if @note.save
      flash[:success] = 'Note was successfully created.'
      redirect_to @note
    else
      render :new
    end
  end

  # PATCH/PUT /notes/1
  def update
    if @note.update(note_params)
      flash[:success] = 'Note was successfully updated.'
      redirect_to @note
    else
      render :edit
    end
  end

  # DELETE /notes/1
  def destroy
    @note.destroy
    flash[:success] = 'Note was successfully destroyed.'
    redirect_to notes_url
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
