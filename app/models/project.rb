class Project < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant

  attr_accessible :name
  validates :name, :presence => true

  def for_tenant(tenant)
    self.tenant = tenant
    return self
  end
end
