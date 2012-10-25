class Mailing
  def initialize(postman, mailing_repository = MailingRepository.null)
    @mailing_repository = mailing_repository
    @postman = postman
  end

  def create_mailing(message, recepient_list)
    mailing_repository.create_mailing(message, recepient_list)
    recepient_list.send_message(message, @postman)
  end

  private
  attr_reader :mailing_repository
end


class RecepientList
  attr_reader :recepients
  def initialize
    @recepients = []
  end

  def add_coordinators(people)
    people.each { |person| add_recepient CoordinatorRecepient, person }
  end

  def add_organizers(people)
    people.each { |person| add_recepient OrganizerRecepient, person }
  end

  def add_conversation_leaders(people)
    people.each { |person| add_recepient ConversationLeaderRecepient, person }
  end

  def add_participants(people)
    people.each { |person| add_recepient ParticipantRecepient, person }
  end

  def add_recepient(recepient_class, person)
    @recepients << recepient_class.new(person)
  end

  def send_message(message, postman)
    @recepients.each { |recepient| recepient.send_message(message, postman) }
  end
end

class Recepient < Struct.new(:person)
  def send_message(message, postman)
    postman.deliver(:mailing_message, message, self)
  end
end

class CoordinatorRecepient < Recepient

end

class OrganizerRecepient < Recepient

end

class ConversationLeaderRecepient < Recepient

end

class ParticipantRecepient < Recepient

end

class RecepientsBuilder
  ValidGroups = { 
    coordinators: CoordinatorRecepient, 
    organizers: OrganizerRecepient, 
    conversation_leaders: ConversationLeaderRecepient, 
    participants: ParticipantRecepient }

  def initialize(project = nil)
    @project = project
    @list = RecepientList.new
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
    @project.send(group).each { |person| @list.add_recepient( class_for(group), person ) }
  end

  def from_people(people)
    people.each { |person| @list.add_recepient Recepient, person }
    @list
  end

  def class_for(group)
    ValidGroups[group.to_sym]
  end

  def valid_group?(group)
    ValidGroups.has_key?(group.to_sym)
  end
end


