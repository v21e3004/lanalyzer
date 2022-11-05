class AddActionToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :action, :string
  end
end
