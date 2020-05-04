class RemoveSessionIdFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :session_id, :string
  end
end
