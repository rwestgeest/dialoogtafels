require 'spec_helper'
require 'mailing'

describe MailingJob do
  describe "perform" do
    it "sets the current tenant and sends the mailing message" do
      tenant = Tenant.new
      postman = Postman
      message = MailingMessage.new
      recipient_list = RecipientList.new
      job = MailingJob.new(tenant, postman, message, recipient_list)
      Tenant.should_receive(:current=).with(tenant)
      recipient_list.should_receive(:send_message).with(message, postman)
      job.perform
    end
  end
end

