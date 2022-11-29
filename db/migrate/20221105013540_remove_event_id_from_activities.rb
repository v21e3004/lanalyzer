class RemoveEventIdFromActivities < ActiveRecord::Migration[5.0]
  def change
    remove_column :activities, :event_id, :integer
  end
end
