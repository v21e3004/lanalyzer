class ChangeDataActivityIdToActivitie < ActiveRecord::Migration[5.0]
  def change
    change_column :activities, :activity_id, :string
  end
end
