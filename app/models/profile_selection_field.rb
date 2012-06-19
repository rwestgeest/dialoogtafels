class ProfileSelectionField < ProfileField
  attr_accessible :values
  include ScopedModel
  scope_to_tenant
  validates_presence_of :label
  validates_presence_of :values
end
