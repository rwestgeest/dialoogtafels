class Mailing
  def initialize(recipient_list, postman, mailing_repository = MailingRepository.null)
    @recipient_list = recipient_list
    @mailing_repository = mailing_repository
    @postman = postman
  end

  def create_mailing(message)
    mailing_repository.create_mailing(message)
    recipient_list.send_message(message, postman)
    return message
  end

  private
  attr_reader :mailing_repository, :postman, :recipient_list
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
    @recipients.each { |recipient| recipient.send_message(message, postman) }
  end
end

class Recipient < Struct.new(:person)
  def send_message(message, postman)
    postman.deliver(:mailing_message, message, person)
  end
end

class CoordinatorRecipient < Recipient

end

class OrganizerRecipient < Recipient

end

class ConversationLeaderRecipient < Recipient

end

class ParticipantRecipient < Recipient

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


