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

