class CleanUpAccountsAndOrganizersWithoutPerson < ActiveRecord::Migration
  def up
    Tenant.all.each do |t|
      Tenant.current = t
      TenantAccount.all.select{|a| a.destroy if a.person.nil? }
      Organizer.all.select{|o| o.destroy if o.person.nil? }
    end
  end

  def down
    # do nothing
  end
end
