class AddColumnToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :date_to_start, :datetime
    add_column :activities, :date_to_submit, :datetime
  end
end
