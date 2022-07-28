class AddActivityNameToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :activity_name, :string
  end
end
