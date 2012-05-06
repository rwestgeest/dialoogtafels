class CreateAdminTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :name, :limit => 50, :null => false
      t.string :url_code, :limit => 50, :null => false
      t.string :representative_name, :limit => 50, :null => false
      t.string :representative_email, :limit => 150, :null => false
      t.string :representative_telephone, :limit => 50, :null => false
      t.text :invoice_address
      t.string :site_url, :limit => 250, :null => false
      t.string :info_email, :limit => 150, :null => false
      t.string :from_email, :limit => 150, :null => false

      t.timestamps
    end
    add_index :tenants, :url_code
  end
end
