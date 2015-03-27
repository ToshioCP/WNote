class Note < ActiveRecord::Base
  belongs_to :section
  validates :title, presence: true
  validates :text, presence: true
  validates :section, presence: true
end
