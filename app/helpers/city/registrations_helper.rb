module City::RegistrationsHelper
  def city_registrations_registration_links(conversation, person)
     [ participant_registration( conversation, "als deelnemer", city_registrations_path(person_id: person.to_param, conversation_id: conversation.to_param, contribution: 'participant'), :method => :post, :remote => true, :disable_with => '... inschrijven'),
       leader_registration(conversation, "als gespreksleider", city_registrations_path(person_id: person.to_param, conversation_id: conversation.to_param, contribution: 'conversation_leader'), :method => :post, :remote => true, :disable_with => '... inschrijven')
     ].compact.join(' | ').html_safe
  end
  def people_filters_for_select
    Person.filters.collect {|filter| [ I18n.t("people_filter_label.#{filter.name}"), filter.name.to_s ] }
  end
end
