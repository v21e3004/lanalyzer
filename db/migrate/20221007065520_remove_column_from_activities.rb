class RemoveColumnFromActivities < ActiveRecord::Migration[5.0]
  def change
    remove_column :activities, :event, :integer
  end
end
