class CreateArticles < ActiveRecord::Migration[4.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :author
      t.date :date

      t.timestamps null: false
    end
  end
end
