class MailingJob < Struct.new(:tenant, :postman, :message, :recepient_list)
  def perform
    Tenant.current = tenant
    recepient_list.send_message(message, postman)
  end
end

