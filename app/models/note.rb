class Note < ApplicationRecord
  belongs_to :section
  has_many :images, dependent: :destroy
  validates :title, presence: true
  validates :text, presence: true
  validates :section, presence: true

  after_create do
    self.section.append_note(self)
  end
  before_update do
    @old_section_id = Note.find(self.id).section_id
    @new_section_id = self.section_id
    @changed = (@old_section_id != @new_section_id)
    if @changed
      Section.find(@old_section_id).delete_note(self)
    end
  end
  after_update do
    if @changed
      Section.find(@new_section_id).append_note(self)
#      self.section.append_note(self)   is also OK.
    end
  end
  before_destroy do
    self.section.delete_note(self)
  end
end
