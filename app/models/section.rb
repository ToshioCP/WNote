class Section < ActiveRecord::Base
  belongs_to :article
  has_many :notes, dependent: :destroy
  validates :heading, presence: true
  validates :article, presence: true
end
