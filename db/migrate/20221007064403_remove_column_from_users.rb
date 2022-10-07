class RemoveColumnFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :event_id, :integer
    remove_column :users, :role, :string
  end
end
