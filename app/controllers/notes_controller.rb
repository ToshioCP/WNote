class NotesController < ApplicationController
  before_action :set_note_variable, except: [:new, :create]
  before_action :set_models_variable
  before_action :verify_user, only: [:new, :create]
  before_action only: [:new, :create, :edit, :update] do
    access_denied if ! edit_permission? @article
  end
  before_action only: :destroy do
    access_denied if ! destroy_permission? @article
  end
  before_action only: :show do
    access_denied if ! read_permission? @article
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
    def set_note_variable
      @note = Note.find(params[:id]) if params[:id]
      if ! @note # params[:id]が無かったか、Note.find(params[:id])で見つからなかった場合
        flash[:warning] = I18n.t('Note_missing')
        redirect_back(fallback_location: root_path)
      end
    end
    def set_models_variable
      @section = @note.section if @note # except new, create
      @section = Section.find(params[:section_id]) if params[:section_id] # new
      @section = Section.find(params[:note][:section_id]) if params[:note] && params[:note][:section_id] # create
      if ! @section
        flash[:warning] = I18n.t('Section_missing')
        redirect_back(fallback_location: root_path)
      end
      @article = @section.article
      if ! @article
        flash[:warning] = I18n.t('Article_missing')
        redirect_back(fallback_location: root_path)
      end
    end
    def note_params
      params.require(:note).permit(:section_id, :title, :text)
    end

end
