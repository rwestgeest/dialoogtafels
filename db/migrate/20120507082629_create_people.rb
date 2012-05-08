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
      t.string :crypted_password
      t.string :password_salt
      t.string :perishable_token
      t.integer :login_count, :null => false, :default => 0
      t.integer :failed_login_count, :null => false, :default => 0

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
