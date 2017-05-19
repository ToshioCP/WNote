class Article < ApplicationRecord
  belongs_to :user
  has_many :sections, dependent: :destroy
  validates :title, presence: true
  validates :author, presence: true
  validates :language, presence: true
  validates :modified_datetime, presence: true
  validates :identifier_uuid, presence: true

  def ordered_sections
    children = []
    ArrayString.new(self.section_order).each do |id|
      children << sections.find(id)
    end
    return children
  end

  def prev_section(section)
    if (as = ArrayString.new(self.section_order).prev(section.id))
      sections.find(as)
    end
  end

  def next_section(section)
    if (as = ArrayString.new(self.section_order).next(section.id))
      sections.find(as)
    end
  end

  def append_section(section)
    update section_order: ArrayString.new(self.section_order).append(section.id)
  end

  def delete_section(section)
    update section_order: ArrayString.new(self.section_order).delete(section.id)
  end
end
