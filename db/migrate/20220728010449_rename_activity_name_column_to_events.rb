class RenameActivityNameColumnToEvents < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :activity_name, :activity_id
  end
end
