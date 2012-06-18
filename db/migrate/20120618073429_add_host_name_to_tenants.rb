class AddHostNameToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :host, :string, limit: 250, null: false, default:''
    add_index  :tenants, :host

    Tenant.reset_column_information
    Tenant.all.each do |t| 
      host = t.url_code == 'test' ? 'test.host' : t.url_code + '.dialoogtafels.nl'
      t.update_attribute :host, host
    end
  end
end
