class Messenger
  def initialize(postman, tenant)
    @postman = postman
    @tenant = tenant
  end

  def new_organizer(organizer)
    postman.deliver(:organizer_confirmation, organizer)
  end

  def new_tenant(created_tenant)
    postman.deliver(:tenant_creation, created_tenant.representative_email, created_tenant)
    postman.deliver(:coordinator_confirmation, created_tenant.coordinator_accounts.first)
  end

  def new_participant(participant) 
    postman.deliver(:new_participant, participant.conversation.location.organizer, participant)
    postman.deliver(:participant_confirmation, participant, tenant)
  end

  def new_conversation_leader(conversation_leader) 
    postman.deliver(:new_conversation_leader, conversation_leader.conversation.location.organizer, conversation_leader)
    postman.deliver(:conversation_leader_confirmation, conversation_leader, tenant)
  end

  def migration_completed(created_tenant)
    Tenant.for created_tenant do
      created_tenant.organizers.each do |organizer| 
        postman.deliver(:migration_completed_for_organizer, organizer)
      end
      created_tenant.coordinator_accounts.each do |coordinator|
        postman.deliver(:migration_completed_for_coordinator, coordinator)
      end
    end
  end

  def self.method_missing(method, *args)
    messenger_instance.send(method, *args)
  end

  private
  def self.messenger_instance
    @messenger_instance ||= Messenger.new(Postman, Tenant.current)
  end
  attr_reader :postman, :tenant
end
