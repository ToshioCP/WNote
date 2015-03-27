class AddReferenceToNotes < ActiveRecord::Migration
  def change
    add_reference :notes, :section, index: true
    add_foreign_key :notes, :sections
  end
end
