class CreateTrainingMessages < ActiveRecord::Migration
  def change
    rename_table :location_comments , :messages
    add_column :messages, :type, :string
    execute "update messages set type='LocationComment'" 
    add_index :messages, :type
    rename_column :messages, :location_id, :reference_id
  end
end
