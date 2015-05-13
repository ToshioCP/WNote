class AdminController < ApplicationController
before_action :admin_check

  def list_users
    @users = User.all
  end

  def delete_user
    id = params[:id]
    User.find(id).destroy
    redirect_to :back, flash: { success: 'User was successfully destroyed.' }
  end

  def reset
#   reset section_order and note_order
    if ENV["RAILS_ENV"] == "development"
      Article.all.each do |article|
        article.update section_order: article.sections.map{|sec| sec.id}.join(',')
        article.sections.each do |section|
          section.update note_order: section.notes.map{|note| note.id}.join(',')
        end
      end
    end
    redirect_to root_path
  end

  private

    def admin_check
      if noadmin?
        flash[:error] = "You don't have access to this section."
        redirect_to :back
      end
    end

end
