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
    send(group).each { |person| @list.add_recipient( class_for(group), person ) }
  end

  def class_for(group)
    ValidGroups[group.to_sym]
  end

  def valid_group?(group)
    ValidGroups.has_key?(group.to_sym)
  end

  private 

  def coordinators
    @project.coordinators
  end

  def organizers
    @project.organizers.select { |organizer| not organizer.locations.empty? }
  end

  def conversation_leaders
    @project.conversation_leaders
  end

  def participants
    @project.participants
  end
end



