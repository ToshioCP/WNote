class ChangeArticles < ActiveRecord::Migration[5.0]
  def change
    change_table :articles do |t|
      t.remove :date
      t.string :language
      t.datetime :modified_datetime
      t.string :identifier_uuid
      t.binary :cover_image, limit: 5.megabytes
      t.text :css
    end
  end
end
