class RemoveActivityIdFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :activity_id, :string
  end
end
