class CreateTrainingMessages < ActiveRecord::Migration
  # this migration creates training messages by 'pulling up' messages from location_comments
  # and adding a type field for single table inheritance
  # to make the change complete the comment_addressees are changed to message_addressees
  def change
    rename_table :location_comments , :messages
    rename_table :comment_addressees, :message_addressees
    add_column :messages, :type, :string
    execute "update messages set type='LocationComment'" 
    add_index :messages, :type
    rename_column :messages, :location_id, :reference_id
    rename_column :message_addressees, :location_comment_id, :message_id
  end
end
