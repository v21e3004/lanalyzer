class RemoveActivityAccessFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :activity_access, :datetime
  end
end
