class CreateFlags < ActiveRecord::Migration[5.0]
  def change
    create_table :flags do |t|
      t.boolean :send

      t.timestamps
    end
  end
end
