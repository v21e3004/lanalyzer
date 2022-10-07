class RemoveTimetable < ActiveRecord::Migration[5.0]
  def change
    drop_table :timetables
  end
end
