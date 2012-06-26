class Participant < Contributor
  attr_accessible :conversation_id

  include ScopedModel
  scope_to_tenant

  validates :email, :unique_account => true,
                    :format => {:with => EMAIL_REGEXP }
  validates :conversation, :presence => true

end
