class ConversationLeader < Contributor
  attr_accessible :conversation_id, :conversation, :person
  belongs_to :conversation, :counter_cache => :conversation_leader_count

  include ScopedModel
  scope_to_tenant

  validates :email, :presence => true,
                    :unique_contributor => true,
                    :format => {:with => EMAIL_REGEXP }
  validates :conversation, :presence => true

  def ordinal_value
    1
  end

end
