class ParticipantAmbition < Contributor
  include ScopedModel
  scope_to_tenant
  validates :person_id, :uniqueness => { scope: :project_id }
end

