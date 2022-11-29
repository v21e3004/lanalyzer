class AddMonitoringToEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_column :enrollments, :monitoring, :boolean, default: true, null: false
  end
end
