class CreateTimetabales < ActiveRecord::Migration[5.0]
  def change
    create_table :timetabales do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
