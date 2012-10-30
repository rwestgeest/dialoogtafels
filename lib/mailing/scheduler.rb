class MailingScheduler < Struct.new(:tenant, :postman, :jobscheduler)
  def self.direct(postman)
    DirectMailingScheduler.new(postman)
  end
  def schedule_message(message, recepient_list)
    jobscheduler.enqueue(MailingJob.new(tenant, postman, message, recepient_list))
  end
end

class DirectMailingScheduler < Struct.new(:postman)
  def schedule_message(message, recepient_list)
    recepient_list.send_message(message, postman)
  end
end

