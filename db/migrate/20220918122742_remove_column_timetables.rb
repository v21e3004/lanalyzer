class RemoveColumnTimetables < ActiveRecord::Migration[5.0]
  def change
    remove_column :timetables, :start_time
    remove_column :timetables, :end_time
  end
end
