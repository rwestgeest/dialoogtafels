require 'spec_helper'
require 'mailing'

describe Mailing do
  let!(:recipient_list) { mock('recipient_list') }
  let!(:message) { MailingMessage.new }
  let!(:postman) { Postman }
  let!(:repository) {  mock(MailingRepository) }


  it "sends a mail message to the recipient list" do
    recipient_list.should_receive(:send_message).with(message, postman)
    a_mailing(recipient_list, postman).create_mailing(message) 
  end

  it "it saves the mailing to the repository" do
    recipient_list.stub :send_message
    repository.should_receive(:create_mailing).with(message)
    a_mailing(recipient_list, postman, repository).create_mailing(message)
  end

  it "it sends nothing when repository save fails" do
    repository.stub(:create_mailing).and_raise RepositorySaveException.new(message)
    recipient_list.should_not_receive :send_message
    expect { a_mailing(recipient_list, postman, repository).create_mailing(message) }.to raise_exception RepositorySaveException
  end

  def a_mailing(*args)
    @mailining ||= Mailing.new(*args)
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
