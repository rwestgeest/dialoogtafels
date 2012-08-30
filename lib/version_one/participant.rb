module VersionOne
class Participant < AbstractParticipant
  validate :participant_email_unique

  def self.create_new creation_attributes, time_slot_preferences = []
    participant = Participant.new(creation_attributes)
    if (participant.valid?)
      participant.save!
      time_slot_preferences.each do |time_slot_id| 
        participant.preferred_time_slots.create(:time_slot_id => time_slot_id) if participant.organizing_city.time_slots.exists?(time_slot_id)
      end
      Postman.deliver(:participant_application_confirmation,participant)
      participant.organizing_city.notify_application(participant, "deelnemer")
    end
    return participant
  end
  
  def self.all_participants
    self.find :all, :order => 'name'
  end
  
  def update_with_notification attributes
    return false unless update_attributes(attributes)
    Postman.deliver(:application_update_confirmation,self)
    organizing_city.notify_application_update(self, "deelnemer")
    return true
  end
 
  protected
  def participant_email_unique
    contributor_email_unique :scope => :type, :message => 'een deelnemer met dit email adres bestaad al'
  end
end
end
