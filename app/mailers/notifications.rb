class Notifications < ActionMailer::Base
  DialoogTafelsMail = "no-reply@dialoogtafels.nl"
  default :from => DialoogTafelsMail

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.account_reset.subject
  #
  def account_reset(account)
    @account = account
    mail from: account.tenant.from_email, to: account.email
  end

  def tenant_creation(tenant)
    @tenant = tenant
    mail to: tenant.representative_email
  end

  def notify_new_registration(to, person, project, role)
    @role = role
    @applicant = person
    mail to: to, from: project.tenant.from_email
  end

  def migration_completed_for_organizer(organizer)
    @organizer = @applicant = organizer
    @tenant = organizer.tenant
    mail to: organizer.email, cc: @tenant.info_email
  end
  
  def migration_completed_for_coordinator(coordinator)
    @coordinator = coordinator
    @tenant = coordinator.tenant
    mail to: coordinator.email
  end

  def new_comment(comment, addressee)
    @comment = comment 
    mail from: addressee.tenant.from_email, to: addressee.email, subject: @comment.subject
  end

  def new_training_invitation(invitation, addressee)
    @invitation = invitation 
    mail from: addressee.tenant.from_email, to: addressee.email, subject: @invitation.subject
  end

  def participant_confirmation(participant, mailing_settings)
    @message = mailing_settings.participant_confirmation_text
    @applicant = participant
    mail from: participant.tenant.from_email, to:participant.email, subject: mailing_settings.participant_confirmation_subject
  end

  def conversation_leader_confirmation(conversation_leader, mailing_settings)
    @message = mailing_settings.conversation_leader_confirmation_text
    @applicant = conversation_leader
    mail from: conversation_leader.tenant.from_email, to:conversation_leader.email, subject: mailing_settings.conversation_leader_confirmation_subject
  end

  def coordinator_confirmation(coordinator)
    @coordinator = coordinator
    @tenant = @coordinator.tenant
    mail from: @tenant.from_email, to:coordinator.email
  end

  def organizer_confirmation(organizer, mailing_settings)
    @message = mailing_settings.organizer_confirmation_text
    @tenant = organizer.tenant
    @applicant = organizer
    mail from: organizer.tenant.from_email, to:organizer.email, subject: mailing_settings.organizer_confirmation_subject
  end

  def new_participant(addressee, person, conversation)
    @participant = person
    @organizer = addressee
    @conversation = conversation
    mail from: person.tenant.from_email, to: addressee.email
  end

  def new_conversation_leader(addressee, person, conversation)
    @conversation_leader = person
    @organizer = addressee
    @conversation = conversation
    mail from: person.tenant.from_email, to: addressee.email
  end

  def mailing_message(message, addressee)
    @message = message 
    mail from: addressee.tenant.from_email, to: addressee.email, subject: @message.subject
  end
end
