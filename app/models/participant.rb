class Participant < Contributor
  attr_accessible :conversation_id
  belongs_to :conversation, :counter_cache => :participant_count

  include ScopedModel
  scope_to_tenant

  validates :email, :presence => true,
            :unique_contributor => true,
            :format => {:with => EMAIL_REGEXP }
  validates :conversation, :presence => true

  def ordinal_value
    2
  end

end
