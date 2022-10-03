class AddSendMessageToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :send_message, :boolean
  end
end
