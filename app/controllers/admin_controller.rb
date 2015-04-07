class AdminController < ApplicationController
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
end
