class AddSectionOrderToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :section_order, :string
  end
end
