require 'spec_helper'
require 'mailing'

describe Mailing do
  let(:recipient_list) { RecipientList.new }
  let(:message) { MailingMessage.new }
  let(:repository) {  mock(MailingRepository) }
  let(:scheduler)  { mock(MailingScheduler) }


  it "sends a mail message to the recipient list" do
    scheduler.should_receive(:schedule_message).with(message, recipient_list)
    a_mailing(scheduler, recipient_list).create_mailing(message) 
  end

  it "it saves the mailing to the repository" do
    scheduler.stub :schedule_message
    repository.should_receive(:create_mailing).with(message)
    a_mailing(scheduler, recipient_list, repository).create_mailing(message)
  end

  it "it sends nothing when repository save fails" do
    repository.stub(:create_mailing).and_raise RepositorySaveException.new(message)
    scheduler.should_not_receive :schedule_message
    expect { a_mailing(scheduler, recipient_list, repository).create_mailing(message) }.to raise_exception RepositorySaveException
  end

  def a_mailing(*args)
    @mailining ||= Mailing.new(*args)
  end
end


