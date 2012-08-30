module VersionOne
class EmailNotifier < ActionMailer::Base

  def generic_message(message, sent_on = Time.now)
    @message = message
    mail :subject => message.subject,
         :to => message.recepients,
         :from => message.sender,
         :cc => message.cc_mail,
         :date => message.sent_at
  end
  
  def new_account_information(account, sent_on = Time.now) 
    @account = account
    mail :subject => 'nieuwe account informatie dialoogtafels.nl',
         :to => account.email,
         :from => account.messages_sender,
         :date => sent_on
  end
  
  def organizer_application_confirmation(organizer, sent_on = Time.now)
    @organizer = organizer
    @organizing_city = organizer.organizing_city
    mail :subject => 'bevestiging van uw aanmelding',
         :to => organizer.email,
         :from => organizer.messages_sender,
         :date => sent_on
  end

  def participant_application_confirmation(participant, sent_on = Time.now)
    @participant = participant
    @organizing_city = participant.organizing_city
    mail :subject => 'bevestiging van uw aanmelding',
         :to => participant.email,
         :from => participant.messages_sender,
         :date => sent_on
  end

  def leader_application_confirmation(person, sent_on = Time.now)
    @leader = person
    @organizing_city = person.organizing_city
    mail :subject => 'bevestiging van uw aanmelding',
         :to =>  person.email,
         :from => person.messages_sender,
         :date => sent_on
  end

  def application_update_confirmation(person, sent_on = Time.now)
    @person = person
    @organizing_city = person.organizing_city
    mail :subject => 'uw registratie is bijgewerkt',
         :to =>  person.email,
         :from => person.messages_sender,
         :date => sent_on
  end
  
  def application_notification(admin, person, type_of_application, sent_on = Time.now)
    @person = person
    @organizing_city = person.organizing_city
    @type_of_application = type_of_application
    mail :subject => 'aanmelding dag van de dialoog',
         :to =>  admin.email,
         :from => admin.messages_sender,
         :date => sent_on
  end
  
  def application_update_notification(admin, person, type_of_application, sent_on = Time.now)
    @person = person
    @organizing_city = person.organizing_city
    @type_of_application = type_of_application
    mail(:to => admin.email,
         :from => admin.messages_sender,
         :subject => 'bijwerking registratie dag van de dialoog',
         :date => sent_on)
  end

end
end
