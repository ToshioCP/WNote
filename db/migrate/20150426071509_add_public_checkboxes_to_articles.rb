class AddPublicCheckboxesToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :w_public, :integer
    add_column :articles, :r_public, :integer
  end
end
