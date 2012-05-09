class AddActiveProjectToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :active_project_id, :integer
  end
end
