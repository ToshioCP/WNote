class User < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :images, dependent: :destroy
  before_save do
    self.email && self.email.downcase!
    self.email_confirmation && self.email_confirmation.downcase!
  end
  validates :name, presence: true, length: {maximum: 64}
  validates :email, presence: true, length: {maximum: 128}, uniqueness: { case_sensitive: false },
                    confirmation: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  }
# The following is written in Rail's Guide.
#   This check is performed only if email_confirmation is not nil. 
#   To require confirmation, make sure to add a presence check for the confirmation attribute 
# But it is inconvenient when updating.
#
# @user = User.find_by(name: 'oldname')
#  :=> @user == {name: 'oldname', email: 'oldemail', password_confirmation: 'digest_of_password...' }
# @user.update(name: 'newname')
# Then rails do
#  1. @user.name = 'newname'
#    :=> @user == {name: 'newname', email: 'oldemail', password_confirmation: 'digest_of_password...' }
# Remark!! @user.email_confirmation == nil
#          @user.password == nil
#          @user.password_confirmation == nil
#  2. @user.save
# Remark!! validation_of_the_presence of email_confirmation prohibits @user.save
#
#  validates :email_confirmation, presence: true
  has_secure_password
  validates :admin, inclusion: { in: [true, false] }
end
