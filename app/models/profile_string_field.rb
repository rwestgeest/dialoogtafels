class ProfileStringField < ProfileField
  include ScopedModel
  scope_to_tenant
  validates_presence_of :label
end
