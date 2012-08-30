module VersionOne
class Leader < AbstractParticipant
  has_many :training_registrations, :dependent => :destroy
  has_many :trainings, :through => :training_registrations

  validate :leader_email_unique

  def self.create_new creation_attributes, time_slot_preferences =[], training_id = nil 
    leader = Leader.new(creation_attributes)
    return leader unless leader.valid_with_training?(training_id)
    leader.register_at_training(training_id)
    if (leader.save)
      time_slot_preferences.each do |time_slot_id| 
        leader.preferred_time_slots.create(:time_slot_id => time_slot_id) if leader.organizing_city.time_slots.exists?(time_slot_id)
      end
      Postman.deliver(:leader_application_confirmation,leader)
      leader.organizing_city.notify_application(leader, "gespreksleider")
    end
    return leader
  end
  
  def valid_with_training?(training_id)
    valid = valid? # to make sure both validations are done
    valid_training?(training_id) && valid
  end

  def valid_training?(training_id)
    return true if organizing_city.trainings.empty? 
    return true if organizing_city.trainings.exists?(training_id)

    errors[:training] << 'u heeft geen training geselecteerd' 
    return false
  end

  def training 
    trainings.first
  end
  
  def update_with_notification attributes, training_id = nil 
    return false unless update_attributes(attributes)
    register_at_training(training_id)
    Postman.deliver(:application_update_confirmation,self)
    organizing_city.notify_application_update(self, "gespreksleider")
    return true
  end
  
  def register_at_training(training_to_register_at)
    return if training_to_register_at.nil?
    begin
      transaction do 
        training_to_register_at = organizing_city.trainings.find(training_to_register_at) if (training_to_register_at.is_an_id?)
        training_to_register_at.register(self)
      end
    rescue ActiveRecord::RecordNotFound
      # ignore
    end
  end

  def cancel_training_registration(training_to_cancel)
    begin
      training_to_cancel = Training.find(training_to_cancel) if (training_to_cancel.is_an_id?)
      training_to_cancel.cancel_registration(self) if training_to_cancel
    rescue ActiveRecord::RecordNotFound
      # ignore
    end
  end

  protected
  def leader_email_unique
    contributor_email_unique(:scope => :type,
                             :message => 'een gespreksleider met dit email adres bestaat al')
  end
end
end
