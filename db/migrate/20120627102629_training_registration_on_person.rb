class TrainingRegistrationOnPerson < ActiveRecord::Migration
  def up
    Tenant.all.each do |tenant|
      Tenant.current = tenant
      TrainingRegistration.all.each do |registration| 
        conversation_leader = ConversationLeader.find(registration.attendee_id)
        puts "setting attendee to #{conversation_leader.person_id}"
        registration.update_attribute :attendee_id, conversation_leader.person_id

      end
    end
  end

  def down
    Tenant.all.each do |tenant|
      Tenant.current = tenant
      TrainingRegistration.all.each do |registration| 
        person = Person.find(registration.attendee_id)
        puts "setting attendee to conversation leader for #{person.id}"
        registration.update_attribute :attendee_id, ConversationLeader.find_by_person_id(person.id).id
      end
    end
  end
end
