module ScopedModelExtensions
  def self.included(base) 
    base.extend(ClassMethods)
  end
  def for_tenant(tenant, &block)
    old_tenant = Tenant.current
    begin
      Tenant.current = tenant if tenant
      yield
    ensure
      Tenant.current = old_tenant
    end
  end
  module ClassMethods
    def prepare_scope(scoped_model)
      before(:all) { Tenant.current= FactoryGirl.create(scoped_model, :url_code => 'test') }
      after(:all) { Tenant.current.destroy }
    end
  end
end
