class AddFieldNameToProfileFields < ActiveRecord::Migration
  def change
    change_table :profile_fields do |t|
      t.string :field_name, :limit => 50, :default => ""
    end
    add_index :profile_fields, :field_name
  end
end
