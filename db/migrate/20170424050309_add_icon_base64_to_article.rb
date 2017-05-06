class AddIconBase64ToArticle < ActiveRecord::Migration[5.0]
  def change
    add_column :articles, :icon_base64, :string
  end
end
