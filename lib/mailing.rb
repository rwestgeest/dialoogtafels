require 'time_period_helper' 

class Mailing
  def initialize(scheduler, recipient_list, mailing_repository = MailingRepository.null)
    @scheduler = scheduler
    @recipient_list = recipient_list
    @mailing_repository = mailing_repository
  end

  def create_mailing(message)
    mailing_repository.create_mailing(message)
    scheduler.schedule_message(message, recipient_list)
    return message
  end

  private
  attr_reader :mailing_repository, :scheduler, :recipient_list
end

class MailingJob < Struct.new(:tenant, :postman, :message, :recepient_list)
  def perform
    Tenant.current = tenant
    recepient_list.send_message(message, postman)
  end
end

class MailingScheduler < Struct.new(:tenant, :postman, :jobscheduler)
  def self.direct(postman)
    DirectMailingScheduler.new(postman)
  end
  def schedule_message(message, recepient_list)
    jobscheduler.enqueue(MailingJob.new(tenant, postman, message, recepient_list))
  end
end

class DirectMailingScheduler < Struct.new(:postman)
  def schedule_message(message, recepient_list)
    recepient_list.send_message(message, postman)
  end
end

class RecipientList
  attr_reader :recipients
  def initialize
    @recipients = []
  end

  def add_recipient(recipient_class, person)
    @recipients << recipient_class.new(person)
  end

  def send_message(message, postman)
    @recipients.each { |recipient| 
      recipient.send_message(message, postman) 
    }
  end
  def include?(person)
    @recipients.map {|r| r.person}.include?(person)
  end
  def ==(other)
    return false unless other.is_a?(RecipientList)
    recipients == other.recipients
  end
end

class Recipient < Struct.new(:person)
  def send_message(message, postman)
    postman.deliver(:mailing_message, wrap_message(message), person)
  end
  private
  def wrap_message(message)
    message.attach_registration_info && wrap_registration_info(message) || message
  end
end

class CoordinatorRecipient < Recipient
  def wrap_registration_info(message)
    CoordinatorRegistrationDetailsMessage.new(message, person)
  end
end

class OrganizerRecipient < Recipient
  def wrap_registration_info(message)
    OrganizerRegistrationDetailsMessage.new(message, person)
  end
end

class ConversationLeaderRecipient < Recipient
  def wrap_registration_info(message)
    ConversationLeaderRegistrationDetailsMessage.new(message, person)
  end
end

class ParticipantRecipient < Recipient
  def wrap_registration_info(message)
    ParticipantRegistrationDetailsMessage.new(message, person)
  end
end

class RecipientsBuilder
  ValidGroups = { 
    coordinators: CoordinatorRecipient, 
    organizers: OrganizerRecipient, 
    conversation_leaders: ConversationLeaderRecipient, 
    participants: ParticipantRecipient }

  def initialize(project = nil)
    @project = project
    @list = RecipientList.new
  end

  def from_groups(groups)
    return @list unless groups
    groups.each do | group |
      add_group(group)
    end
    @list
  end

  def add_group(group)
    return unless valid_group?(group)
    @project.send(group).each { |person| @list.add_recipient( class_for(group), person ) }
  end

  def class_for(group)
    ValidGroups[group.to_sym]
  end

  def valid_group?(group)
    ValidGroups.has_key?(group.to_sym)
  end
end

class RegistrationDetailsMessage < Struct.new(:message, :person)
  include TimePeriodHelper
  def body
    [ message.body, '-----------', '## Registratie details', body_attachment ].join("\n\n")
  end
  def body_attachment
    ''
  end
  def subject
    message.subject
  end

  def join_lines(what)
    what.join("\n\n")
  end
  def person_details(person)
    "* #{person.name}, #{person.email}, #{person.telephone}"
  end
end

class CoordinatorRegistrationDetailsMessage < RegistrationDetailsMessage
  def body_attachment
    %Q{Registratie details worden hier ingevuld voor de deelnemers, gespreksleiders en organisatoren}
  end
end

class OrganizerRegistrationDetailsMessage < RegistrationDetailsMessage

  def body_attachment
    join_lines person.locations.collect {|location| location_details(location) }
  end

  def location_details(location)
    join_lines( ["### #{location.name}, #{location.address}, #{location.postal_code}, #{location.city}"] + 
                 location.conversations.collect {|conversation| conversation_details(conversation) } )
  end

  def conversation_details(conversation)
    join_lines([ "#### #{conversation.number_of_tables} tafel(s) #{time_period(conversation)}" ] +
                 ["##### Gespreksleider(s):"] + 
                 conversation.conversation_leaders.collect {|conversation_leader| person_details(conversation_leader) } +
                 ["##### Deelnemer(s):"] +
                 conversation.participants.collect {|participant| person_details(participant) }  )
  end

end

class ConversationLeaderRegistrationDetailsMessage < RegistrationDetailsMessage
  def body_attachment
    conversation_details person.conversation
  end
  def conversation_details(conversation)
    conversation_details = [ "#### #{conversation.number_of_tables} tafel(s) #{time_period(conversation)}",
                             "##### Locatie: #{location_details(conversation.location)}", 
                             "##### Organisator:", person_details(conversation.organizer) ]
    if conversation.number_of_tables == 1
      conversation_details +=
                 ["##### Gespreksleider(s):"] + 
                 conversation.conversation_leaders.collect {|conversation_leader| person_details(conversation_leader) } +
                 ["##### Deelnemer(s):"] +
                 conversation.participants.collect {|participant| person_details(participant) }  

    end
    join_lines(conversation_details)
  end
  def location_details(location)
    "#{location.name}, #{location.address}, #{location.postal_code}, #{location.city}"
  end
end

class ParticipantRegistrationDetailsMessage < RegistrationDetailsMessage
  def body_attachment
    conversation_details person.conversation
  end
  def conversation_details(conversation)
    conversation_details = [ "#### #{conversation.number_of_tables} tafel(s) #{time_period(conversation)}" ,
                             "##### Locatie: #{location_details(conversation.location)}", 
                             "##### Organisator:", person_details(conversation.organizer) ] 
    join_lines(conversation_details)
  end
  def location_details(location)
    "#{location.name}, #{location.address}, #{location.postal_code}, #{location.city}"
  end
end

