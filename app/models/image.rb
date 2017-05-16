class Image < ApplicationRecord
  belongs_to :user
  validates :name, presence: true, uniqueness: true
  validates :image, presence: true, length: {maximum: 3.megabytes}
end
