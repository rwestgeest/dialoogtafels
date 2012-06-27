module City::RegistrationsHelper
  def city_registrations_registration_links(conversation, person)
     [ participant_registration( conversation, "als deelnemer", city_registrations_path(person_id: person.to_param, conversation_id: conversation.to_param, contribution: 'participant'), :method => :post, :remote => true),
       leader_registration(conversation, "als gespreksleider", city_registrations_path(person_id: person.to_param, conversation_id: conversation.to_param, contribution: 'conversation_leader'), :method => :post, :remote => true)
     ].compact.join(' | ').html_safe
  end
end
