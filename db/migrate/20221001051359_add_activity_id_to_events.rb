class AddActivityIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_reference :events, :activity, foreign_key: true
  end
end
