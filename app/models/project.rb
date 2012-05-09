class Project < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant

  attr_accessible :name
  validates :name, :presence => true

end
