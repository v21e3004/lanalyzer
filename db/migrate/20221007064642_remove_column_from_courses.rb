class RemoveColumnFromCourses < ActiveRecord::Migration[5.0]
  def change
    remove_column :courses, :start_time, :datetime
    remove_column :courses, :end_time, :datetime
    remove_column :courses, :send_message, :boolean
  end
end
