class CreateCityProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.references :tenant
      t.timestamps
    end
    add_column :tenants, :current_project_id, :integer
    add_index :tenants, :current_project_id
  end
end
