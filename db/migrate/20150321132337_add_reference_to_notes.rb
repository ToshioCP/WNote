class AddReferenceToNotes < ActiveRecord::Migration[4.2]
  def change
    add_reference :notes, :section, index: true
    add_foreign_key :notes, :sections
  end
end
