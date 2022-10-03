class AddLessonToTimetable < ActiveRecord::Migration[5.0]
  def change
    add_column :timetables, :lesson1, :datetime
    add_column :timetables, :lesson2, :datetime
    add_column :timetables, :lesson3, :datetime
    add_column :timetables, :lesson4, :datetime
    add_column :timetables, :lesson5, :datetime
    add_column :timetables, :lesson6, :datetime
    add_column :timetables, :lesson7, :datetime
    add_column :timetables, :lesson8, :datetime
    add_column :timetables, :lesson9, :datetime
    add_column :timetables, :lesson10, :datetime
    add_column :timetables, :lesson11, :datetime
    add_column :timetables, :lesson12, :datetime
    add_column :timetables, :lesson13, :datetime
    add_column :timetables, :lesson14, :datetime
    add_column :timetables, :lesson15, :datetime
  end
end
