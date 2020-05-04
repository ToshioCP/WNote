class AddUserRefToArticles < ActiveRecord::Migration[4.2]
  def change
    add_reference :articles, :user, index: true
    add_foreign_key :articles, :users
  end
end
