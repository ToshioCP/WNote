class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :heading
      t.references :article, index: true

      t.timestamps null: false
    end
    add_foreign_key :sections, :articles
  end
end
