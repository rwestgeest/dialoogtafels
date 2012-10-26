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

    context "when message should include subscription info" do
      before { message.attach_registration_info = true}
      it "wraps message in CoordinatorRegistrationDetailsMessage" do
        postman.should_receive(:deliver).with(:mailing_message, CoordinatorRegistrationDetailsMessage.new(message, recipient.person), recipient.person)
        recipient.send_message(message, postman)
      end
    end
  end

  describe OrganizerRecipient do
    let(:recipient) { OrganizerRecipient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recipient")

    context "when message should include subscription info" do
      before { message.attach_registration_info = true}
      it "wraps message in CoordinatorRegistrationDetailsMessage" do
        postman.should_receive(:deliver).with(:mailing_message, OrganizerRegistrationDetailsMessage.new(message, recipient.person), recipient.person)
        recipient.send_message(message, postman)
      end
    end
  end

  describe ConversationLeaderRecipient do
    let(:recipient) { ConversationLeaderRecipient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recipient")

    context "when message should include subscription info" do
      before { message.attach_registration_info = true}
      it "wraps message in CoordinatorRegistrationDetailsMessage" do
        postman.should_receive(:deliver).with(:mailing_message, ConversationLeaderRegistrationDetailsMessage.new(message, recipient.person), recipient.person)
        recipient.send_message(message, postman)
      end
    end
  end

  describe ParticipantRecipient do
    let(:recipient) { ParticipantRecipient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recipient")

    context "when message should include subscription info" do
      before { message.attach_registration_info = true}
      it "wraps message in CoordinatorRegistrationDetailsMessage" do
        postman.should_receive(:deliver).with(:mailing_message, ParticipantRegistrationDetailsMessage.new(message, recipient.person), recipient.person)
        recipient.send_message(message, postman)
      end
    end
  end
end

describe "RegistrationDetailsMessage" do
  let(:message) { MailingMessage.new :body => 'original body', :subject => 'subject' } 

  shared_examples_for RegistrationDetailsMessage do
    its(:body)    { should include(message.body) }
    its(:body) { should include('-----------') }
    its(:body) { should include "## Registratie details" }
    its(:subject) { should ==  message.subject   }
  end

  describe CoordinatorRegistrationDetailsMessage do
    subject { CoordinatorRegistrationDetailsMessage.new message } 
    it_should_behave_like RegistrationDetailsMessage
    its(:body) { should include "Registratie details worden hier ingevuld voor de deelnemers, gespreksleiders en organisatoren" }
  end

  describe OrganizerRegistrationDetailsMessage do
    prepare_scope :tenant
    let(:organizer) { FactoryGirl.create :organizer } 
    subject { OrganizerRegistrationDetailsMessage.new message, organizer } 
    
    it_should_behave_like RegistrationDetailsMessage

    describe "when he has a location" do
      let!(:location) { FactoryGirl.create(:location, organizer: organizer) } 
      
      its(:body) { should include location.name }
      its(:body) { should include location.address }
      its(:body) { should include location.postal_code }
      its(:body) { should include location.city }

      describe "when the location has a conversation" do
        include TimePeriodHelper
        let!(:conversation) { FactoryGirl.create(:conversation, location: location) }
        its(:body) { should include time_period(conversation) } 
        its(:body) { should include "#{conversation.number_of_tables} tafel(s)" } 
        its(:body) { should include "Gespreksleider(s):" }
        its(:body) { should include "Deelnemer(s):" }
        describe "when it the conversation has conversation leaders" do
          let!(:conversation_leader) { FactoryGirl.create(:conversation_leader, conversation: conversation) }
          its(:body) { should include conversation_leader.name } 
          its(:body) { should include conversation_leader.email } 
          its(:body) { should include conversation_leader.telephone } 
        end
        describe "when it the conversation has participants leaders" do
          let!(:participant) { FactoryGirl.create(:participant, conversation: conversation) }
          its(:body) { should include participant.name } 
          its(:body) { should include participant.email } 
          its(:body) { should include participant.telephone} 
        end
      end
    end
  end

  describe ConversationLeaderRegistrationDetailsMessage do
    prepare_scope :tenant

    let!(:conversation) { FactoryGirl.create(:conversation) }
    let!(:conversation_leader) { FactoryGirl.create(:conversation_leader, conversation: conversation) }
    let(:location) { conversation.location }
    let(:organisator) { location.organizer } 

    subject { ConversationLeaderRegistrationDetailsMessage.new message, conversation_leader } 

    it_should_behave_like RegistrationDetailsMessage

    describe "registered to a conversation" do 
      include TimePeriodHelper
      before { conversation.update_attribute :number_of_tables, 2 } 
      its(:body) { should include time_period(conversation) }
      its(:body) { should include "#{conversation.number_of_tables} tafel(s)" } 
      its(:body) { should include "Locatie:" }
      its(:body) { should include location.name }
      its(:body) { should include location.address }
      its(:body) { should include location.postal_code }
      its(:body) { should include location.city }
      its(:body) { should include "Organisator:" }
      its(:body) { should include organisator.name } 
      its(:body) { should include organisator.email } 
      its(:body) { should include organisator.telephone } 
      its(:body) { should_not include "Gespreksleider(s)" }

      describe "when number of tables is one" do
        before { conversation.update_attribute :number_of_tables, 1 } 
        its(:body) { should include "Gespreksleider(s):" }
        its(:body) { should include conversation_leader.name } 
        its(:body) { should include conversation_leader.email } 
        its(:body) { should include conversation_leader.telephone } 

        its(:body) { should include "Deelnemer(s):" }
        describe "when it the conversation has participants leaders" do
          let!(:participant) { FactoryGirl.create(:participant, conversation: conversation) }
          its(:body) { should include participant.name } 
          its(:body) { should include participant.email } 
          its(:body) { should include participant.telephone} 
        end

      end
    end
  end

  describe ParticipantRegistrationDetailsMessage do
    prepare_scope :tenant

    let!(:conversation) { FactoryGirl.create(:conversation) }
    let!(:participant) { FactoryGirl.create(:participant, conversation: conversation) }
    let(:location) { conversation.location }
    let(:organisator) { location.organizer } 

    subject { ParticipantRegistrationDetailsMessage.new message, participant } 

    it_should_behave_like RegistrationDetailsMessage

    describe "registered to a conversation" do 
      include TimePeriodHelper
      its(:body) { should include time_period(conversation) }
      its(:body) { should include "#{conversation.number_of_tables} tafel(s)" } 
      its(:body) { should include "Locatie:" }
      its(:body) { should include location.name }
      its(:body) { should include location.address }
      its(:body) { should include location.postal_code }
      its(:body) { should include location.city }
      its(:body) { should include "Organisator:" }
      its(:body) { should include organisator.name } 
      its(:body) { should include organisator.email } 
      its(:body) { should include organisator.telephone } 
    end

  end
end

