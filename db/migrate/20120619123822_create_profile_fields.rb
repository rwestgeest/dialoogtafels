class CreateProfileFields < ActiveRecord::Migration
  def change
    create_table :profile_fields do |t|
      t.string :label, limit: 50, default: ""
      t.string :type,  limit: 1000
      t.text :values, default:""
      t.integer :order, default:0
      t.references :tenant
      t.timestamps
    end
    add_index :profile_fields, [:tenant_id, :order]

    create_table :profile_field_values do |t|
      t.references :person
      t.references :profile_field
      t.string :value
      t.references :tenant
    end
    add_index :profile_field_values, [ :tenant_id, :person_id ]
    add_index :profile_field_values, [ :tenant_id, :profile_field_id ]
  end
end
