class ConversationLeader < Contributor
  attr_accessible :conversation_id, :conversation, :person
  has_many :training_registrations, :foreign_key => :attendee_id, :include => :training, :dependent => :destroy
  has_many :trainings, :through => :training_registrations
  belongs_to :conversation, :counter_cache => :conversation_leader_count

  include ScopedModel
  scope_to_tenant

  validates :email, :presence => true,
                    :unique_account => true,
                    :format => {:with => EMAIL_REGEXP }
  validates :conversation, :presence => true

  def register_for training
    begin 
      return register_for Training.find(training) unless training.is_a? Training
      trainings << training
      return training
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  def cancel_registration_for training
    begin 
      training = trainings.find(training)
      trainings.delete training
      return training
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end
end
