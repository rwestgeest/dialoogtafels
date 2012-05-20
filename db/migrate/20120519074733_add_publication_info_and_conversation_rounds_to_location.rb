class AddPublicationInfoAndConversationRoundsToLocation < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t| 
      t.datetime :start_at
      t.datetime :end_at
      t.references :tenant, :null => false
      t.references :location, :null => false
    end
    change_table :locations do |t|
      t.has_attached_file :photo
      t.boolean :published, :default => false
    end
  end
  def self.down
    drop_table :conversations
    drop_attached_file :locations, :photo
    drop_column :locations, :photo
  end
end
