class Section < ApplicationRecord
  belongs_to :article
  has_many :notes, dependent: :destroy
  validates :heading, presence: true
  validates :article, presence: true

  after_create do
    self.article.append_section(self)
  end
  before_update do
    @old_article_id = Section.find(self.id).article_id
    @new_article_id = self.article_id
    @changed = (@old_article_id != @new_article_id)
    if @changed
      Article.find(@old_article_id).delete_section(self)
    end
  end
  after_update do
    if @changed
      Article.find(@new_article_id).append_section(self)
#      self.article.append_section(self)    is also OK.
    end
  end
  before_destroy do
    self.article.delete_section(self)
  end

  def ordered_notes
    children = []
    ArrayString.new(self.note_order).each do |id|
      children << notes.find(id)
    end
    return children
  end

  def prev_note(note)
    if (as = ArrayString.new(self.note_order).prev(note.id))
      notes.find(as)
    end
  end

  def next_note(note)
    if (as = ArrayString.new(self.note_order).next(note.id))
      notes.find(as)
    end
  end

  def append_note(note)
    update note_order: ArrayString.new(self.note_order).append(note.id)
  end

  def delete_note(note)
    update note_order: ArrayString.new(self.note_order).delete(note.id)
  end

end
