class Participant < Contributor
  attr_accessible :conversation_id
  belongs_to :conversation, :counter_cache => :participant_count

  include ScopedModel
  scope_to_tenant

  validates :email, :unique_account => true,
                    :format => {:with => EMAIL_REGEXP }
  validates :conversation, :presence => true

  def save_with_notification
    save && Postman.deliver(:new_participant, self)
  end
end
