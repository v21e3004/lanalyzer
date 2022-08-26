class AddLastStatusToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :status, :boolean, default: false, null: false
  end
end
