class AddNoteOrderToSections < ActiveRecord::Migration
  def change
    add_column :sections, :note_order, :string
  end
end
