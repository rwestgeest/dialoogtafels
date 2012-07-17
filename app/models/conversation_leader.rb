class ConversationLeader < Contributor
  attr_accessible :conversation_id, :conversation, :person
  belongs_to :conversation, :counter_cache => :conversation_leader_count

  include ScopedModel
  scope_to_tenant

  validates :email, :presence => true,
                    :format => {:with => EMAIL_REGEXP }
  validates :conversation, :presence => true

  def ordinal_value
    1
  end

  def first_landing_page
    if account.role == Account::Coordinator
      "/city/registrations?person_id=#{account.person_id}"
    else
      '/registration/conversation_leaders/confirm'
    end
  end

  def save_with_notification
    save && Postman.deliver(:new_conversation_leader, self, conversation.organizer)
  end

end
