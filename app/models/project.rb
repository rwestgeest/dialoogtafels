class Project < ActiveRecord::Base
  belongs_to :tenant

  attr_accessible :name, :tenant_id

  validates :name, :presence => true
  validates :tenant, :presence => true

  default_scope lambda { where :tenant_id => Tenant.current }
end
