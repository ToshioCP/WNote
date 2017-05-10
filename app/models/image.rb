class Image < ApplicationRecord
  belongs_to :note
  validates :name, presence: true
  validates :image, presence: true, length: {maximum: 3.megabytes}
end
