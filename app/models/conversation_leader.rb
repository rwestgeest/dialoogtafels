class ConversationLeader < Contributor
  attr_accessible :conversation_id
  belongs_to :conversation
  has_many :training_registrations, :foreign_key => :attendee_id
  has_many :trainings, :through => :training_registrations

  include ScopedModel
  scope_to_tenant

  validates :email, :presence => true,
                    :unique_account => true,
                    :format => {:with => EMAIL_REGEXP }
  validates :conversation, :presence => true

end
