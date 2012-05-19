class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name, :limit => 100
      t.string :postal_code, :limit => 10, :null => false
      t.string :address, :limit => 100, :null => false
      t.string :city, :limit => 100, :null => false
      t.float  :lattitude,  :default => nil
      t.float  :longitude,  :default => nil
      t.references :project, :null => false
      t.references :tenant, :null => false
      t.references :organizer, :null => false
      t.timestamps
    end
  end
end
