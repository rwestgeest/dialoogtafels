module ScopedModel
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  module ClassMethods
    def scope_to_tenant
      belongs_to :tenant
      default_scope lambda { where(:tenant_id => Tenant.current) }
      validates :tenant, :presence => true
    end
  end
end


