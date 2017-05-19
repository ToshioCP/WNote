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
  end

  def create
    @note = Note.new(note_params)
    if @note.save
      flash[:success] = I18n.t('x_created', x: I18n.t('Note'))
      redirect_to @note
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
      flash[:success] = I18n.t('x_updated', x: I18n.t('Note'))
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
    flash[:success] = I18n.t('x_destroyed', x: I18n.t('Note'))
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
        flash[:warning] = I18n.t('note_or_section_not_being_read')
        redirect_back(fallback_location: root_path)
      end
    end
    def note_params
      params.require(:note).permit(:section_id, :title, :text)
    end

end
