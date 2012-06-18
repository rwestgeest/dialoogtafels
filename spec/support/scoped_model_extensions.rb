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
      before(:all) { 
        begin
        Tenant.current= FactoryGirl.create(scoped_model, :url_code => 'test', :host => 'test.host') 
        rescue Exception => e
          p "could not create current scope"
        end

      }
      after(:all) { Tenant.current.destroy if Tenant.current }
    end
  end
end
