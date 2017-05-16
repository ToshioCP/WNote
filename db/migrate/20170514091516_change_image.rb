class ChangeImage < ActiveRecord::Migration[5.1]
  def change
    change_table :images do |t|
      t.remove :note_id
      t.references :user, foreign_key: true
# foreign_key: true をつけると、indexもつく。
      t.index :name, unique: true
    end
  end
end
