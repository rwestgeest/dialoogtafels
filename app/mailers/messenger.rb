class Messenger
  def initialize(postman, tenant)
    @postman = postman
    @tenant = tenant
  end

  def new_organizer(organizer)
    postman.deliver(:organizer_confirmation, organizer, tenant.active_project)
  end

  def new_tenant(created_tenant)
    Tenant.for created_tenant do
      postman.deliver(:tenant_creation, created_tenant)
      postman.deliver(:coordinator_confirmation, created_tenant.coordinator_accounts.first)
    end
  end

  def new_participant(person, conversation) 
    postman.deliver(:new_participant, conversation.location.organizer, person, conversation)
    postman.deliver(:participant_confirmation, person, tenant.active_project)
  end

  def new_participant_ambition(person) 
    postman.deliver(:participant_confirmation, person, tenant.active_project)
  end

  def new_conversation_leader(person, conversation) 
    postman.deliver(:new_conversation_leader, conversation.location.organizer, person, conversation)
    postman.deliver(:conversation_leader_confirmation, person, tenant.active_project)
  end

  def new_conversation_leader_ambition(person) 
    postman.deliver(:conversation_leader_confirmation, person, tenant.active_project)
  end

  def migration_completed(created_tenant)
    Tenant.for created_tenant do
      created_tenant.organizers.each do |organizer| 
        postman.deliver(:migration_completed_for_organizer, organizer.person)
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
    Messenger.new(Postman, Tenant.current)
  end
  attr_reader :postman, :tenant
end
