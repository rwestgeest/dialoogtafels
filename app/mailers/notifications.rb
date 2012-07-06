class Notifications < ActionMailer::Base

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.account_reset.subject
  #
  def account_reset(account)
    @account = account
    mail from: account.tenant.from_email, to: account.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.account_welcome.subject
  #
  def account_welcome(account)
    @account = account
    mail from:account.tenant.from_email, to: account.email
  end

  def new_comment(comment, addressee)
    @comment = comment 
    mail from: addressee.tenant.from_email, to: addressee.email, subject: @comment.subject
  end

  def new_training_invitation(invitation, addressee)
    @invitation = invitation 
    mail from: addressee.tenant.from_email, to: addressee.email, subject: @invitation.subject
  end

  def new_participant(participant, addressee)
    @participant = participant
    @organizer = addressee
    @conversation = participant.conversation
    mail from: participant.tenant.from_email, to: addressee.email
  end

  def new_conversation_leader(conversation_leader, addressee)
    @conversation_leader = conversation_leader
    @organizer = addressee
    @conversation = conversation_leader.conversation
    mail from: conversation_leader.tenant.from_email, to: addressee.email
  end
end
