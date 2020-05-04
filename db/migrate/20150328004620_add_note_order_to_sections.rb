class AddNoteOrderToSections < ActiveRecord::Migration[4.2]
  def change
    add_column :sections, :note_order, :string
  end
end
