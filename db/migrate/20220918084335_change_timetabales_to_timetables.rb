class ChangeTimetabalesToTimetables < ActiveRecord::Migration[5.0]
  def change
    rename_table :timetabales, :timetables
  end
end
