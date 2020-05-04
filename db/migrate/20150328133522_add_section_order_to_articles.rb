class AddSectionOrderToArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :articles, :section_order, :string
  end
end
