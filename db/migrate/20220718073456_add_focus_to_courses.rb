class AddFocusToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :focus, :boolean, default: false, null: false
  end
end
