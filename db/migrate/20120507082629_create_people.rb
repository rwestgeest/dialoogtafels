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
      t.string :encrypted_password
      t.string :password_salt
      t.string :perishable_token
      t.datetime :confirmed_at, :null => true

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
