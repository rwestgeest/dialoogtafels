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


describe RecipientsBuilder do
  let(:project) { stub(Project) }
  let(:people_to_mail) { [person1, person2] }
  let(:person1) { Account.new(email: "one@mail.com") }
  let(:person2) { Account.new(email: "two@mail.com") }

  describe "from_groups" do

    context "when groups contains coordinators" do
      before { project.stub(:coordinators).and_return people_to_mail }
      let(:subject) {  RecipientsBuilder.new(project).from_groups(['coordinators']) }

      its(:recipients) { should == [CoordinatorRecipient.new(person1), CoordinatorRecipient.new(person2)] }
    end

    context "when groups contains organizers" do
      before { project.stub(:organizers).and_return people_to_mail }
      let(:subject) {  RecipientsBuilder.new(project).from_groups(['organizers']) }

      its(:recipients) { should == [OrganizerRecipient.new(person1), OrganizerRecipient.new(person2)] }
    end

    context "when groups contains conversation_leaders" do
      before { project.stub(:conversation_leaders).and_return people_to_mail }
      let(:subject) {  RecipientsBuilder.new(project).from_groups(['conversation_leaders']) }

      its(:recipients) { should == [ConversationLeaderRecipient.new(person1), ConversationLeaderRecipient.new(person2)] }
    end

    context "when groups contains participants" do
      before { project.stub(:participants).and_return people_to_mail }
      let(:subject) {  RecipientsBuilder.new(project).from_groups(['participants']) }

      its(:recipients) { should == [ParticipantRecipient.new(person1), ParticipantRecipient.new(person2)] }
    end

    context "when groups contains something silly" do
      let(:subject) {  RecipientsBuilder.new(project).from_groups(['bogusgroup']) }

      its(:recipients) { should be_empty }
    end

    context "when groups is nil" do
      let(:subject) {  RecipientsBuilder.new(project).from_groups(nil) }

      its(:recipients) { should be_empty }
    end

  end
end

describe RecipientList do
  describe "send_message" do
    let(:message) { Message.new }
    let(:postman) { Postman }
    let(:project) { stub(Project, coordinators: [a_person_with_email('e@mail.com')], organizers: [a_person_with_email('f@mail.com')]) }

    it "sends it to its list of recipients" do
      recipientlist = RecipientsBuilder.new(project).from_groups ['coordinators', 'organizers']
      recipientlist.recipients[0].should_receive(:send_message).with(message, postman)
      recipientlist.recipients[1].should_receive(:send_message).with(message, postman)
      recipientlist.send_message(message, postman)
    end
  end

  def a_person_with_email(email)
    Account.new(email: email)
  end
end

describe Recipient do
  let(:message) { MailingMessage.new } 
  let(:postman) { mock Postman } 
  shared_examples_for("a_recipient") do
    describe "send_message" do
      it "sends the message to the postman" do
        postman.should_receive(:deliver).with(:mailing_message, message, recipient.person)
        recipient.send_message(message, postman)
      end
    end
  end

  describe CoordinatorRecipient do
    let(:recipient) { CoordinatorRecipient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recipient")
  end

  describe OrganizerRecipient do
    let(:recipient) { OrganizerRecipient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recipient")
  end

  describe ConversationLeaderRecipient do
    let(:recipient) { ConversationLeaderRecipient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recipient")
  end

  describe ParticipantRecipient do
    let(:recipient) { ParticipantRecipient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recipient")
  end
end
