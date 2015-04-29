class RemoveSessionIdFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :session_id, :string
  end
end
