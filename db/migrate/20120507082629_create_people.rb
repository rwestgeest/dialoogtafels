class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name, :limit => 50, :null => false
      t.string :telephone, :limit => 50, :null => false
      t.references :project
      t.references :tenant
      t.timestamps
    end

    create_table :accounts do |t| 
      t.string :email, :limit => 150, :null => false
      t.string :role, :limit => 50, :null => false, :default => 'admin'
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.string :persistence_token, :null => false
      t.string :perishable_token, :null => false
      t.integer :login_count, :null => false, :default => 0
      t.integer :failed_login_count, :null => false, :default => 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip

      t.references :project
      t.references :tenant
      t.references :person
      t.timestamps
    end

    create_table :contributors do |t|
      t.string :type
      t.references :project
      t.references :tenant
      t.references :person
      t.timestamps
    end

  end
end
