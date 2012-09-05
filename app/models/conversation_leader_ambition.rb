class ConversationLeaderAmbition < Contributor
  include ScopedModel
  scope_to_tenant
  validates :person_id, :uniqueness => true
end

