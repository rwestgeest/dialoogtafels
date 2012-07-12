class AddLayoutForPublicPagesToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :framed_integration, :boolean, default: false
  end
end
