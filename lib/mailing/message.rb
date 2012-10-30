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

