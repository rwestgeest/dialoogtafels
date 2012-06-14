class TenantAccount < Account

  include ScopedModel
  scope_to_tenant
  validates_presence_of :person

  class << self 
    def coordinator(attributes = {})
      account_with_tenant attributes.merge(:role => Account::Coordinator)
    end
    def contributor(person, attributes = {})
      a = account_with_tenant attributes.merge(:role => Account::Contributor)
      a.person = person
      a
    end
    private
    def account_with_tenant(attributes)
      a = TenantAccount.new(attributes)
      a.tenant = Tenant.current
      a
    end
  end

end
