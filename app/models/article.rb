class Article < ActiveRecord::Base
  has_many :sections, dependent: :destroy
  validates :title, presence: true
  validates :author, presence: true
  validates :date, presence: true
end
