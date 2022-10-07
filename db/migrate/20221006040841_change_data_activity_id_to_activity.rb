class ChangeDataActivityIdToActivity < ActiveRecord::Migration[5.0]
  def change
    change_column :activities, :activity_id, :integer
  end
end
