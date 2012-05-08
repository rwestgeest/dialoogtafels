module ControllerExtensions

  def self.included(base) 
    base.extend(ClassMethods)
  end
  module ClassMethods
    def prepare_scope(scoped_model)
      before(:all) { Tenant.current= FactoryGirl.create(scoped_model, :url_code => 'test') }
      after(:all) { Tenant.current.destroy }
    end
  end
end

