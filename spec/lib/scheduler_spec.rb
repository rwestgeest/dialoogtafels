require 'spec_helper'
require 'mailing'

describe MailingScheduler do
  prepare_scope :tenant
  let(:recipient_list) {RecipientList.new}
  let(:message) { FactoryGirl.create :mailing_message }
  let(:tenant)  { Tenant.current }
  let(:postman) { Postman }
  let(:scheduler) { MailingScheduler.new(tenant, postman, Delayed::Job) }

  it "enqueues_jobs_to_jobscheduler" do
    expect { scheduler.schedule_message(message, recipient_list) }.to change(Delayed::Job, :count).by(1)
  end
  it "enqueued job is a mailing job" do
    scheduler.schedule_message(message, recipient_list) 
    begin
      Delayed::Job.last.payload_object.should == MailingJob.new(tenant, postman, message, recipient_list)
    rescue Exception => e
      p e.message
      raise e
    end
  end
end


