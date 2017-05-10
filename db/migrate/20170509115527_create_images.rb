class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :name
      t.binary :image, limit: 3.megabytes
      t.references :note, index: true

      t.timestamps
    end
  end
end
