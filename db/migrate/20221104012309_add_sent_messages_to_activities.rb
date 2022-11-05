class AddSentMessagesToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :sent_messages, :boolean
  end
end
