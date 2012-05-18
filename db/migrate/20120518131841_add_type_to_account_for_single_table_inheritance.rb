class AddTypeToAccountForSingleTableInheritance < ActiveRecord::Migration
  def change
    add_column :accounts, :type, :string, :limit => 20
    add_index :accounts, :type
    Account.reset_column_information
    Account.all.each do |a|
      if a.role = Account.Maintainer
        a.update_attribute :type, 'MaintainerAccount'
      else
        a.update_attribute :type, 'TenantAccount'
      end
    end
  end
end
