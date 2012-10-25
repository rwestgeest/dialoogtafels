require 'spec_helper'
require 'mailing'

describe Mailing do
  let!(:recepient_list) { mock('recepient_list') }
  let!(:message) { MailingMessage.new }
  let!(:postman) { Postman }
  let!(:repository) {  mock(MailingRepository) }


  it "sends a mail message to the recepient list" do
    recepient_list.should_receive(:send_message).with(message, postman)
    a_mailing(postman).create_mailing(message, recepient_list) 
  end

  it "it saves the mailing to the repository" do
    recepient_list.stub :send_message
    repository.should_receive(:create_mailing).with(message, recepient_list)
    a_mailing(postman, repository).create_mailing(message, recepient_list)
  end

  it "it sends nothing when repository save fails" do
    repository.stub(:create_mailing).and_raise RepositorySaveException.new(message)
    recepient_list.should_not_receive :send_message
    expect { a_mailing(postman, repository).create_mailing(message, recepient_list) }.to raise_exception RepositorySaveException
  end

  def a_mailing(*args)
    @mailining ||= Mailing.new(*args)
  end
end

describe RecepientsBuilder do
  let(:project) { stub(Project) }
  let(:people_to_mail) { [person1, person2] }
  let(:person1) { Account.new(email: "one@mail.com") }
  let(:person2) { Account.new(email: "two@mail.com") }

  describe "from_groups" do

    context "when groups contains coordinators" do
      before { project.stub(:coordinators).and_return people_to_mail }
      let(:subject) {  RecepientsBuilder.new(project).from_groups(['coordinators']) }

      its(:recepients) { should == [CoordinatorRecepient.new(person1), CoordinatorRecepient.new(person2)] }
    end

    context "when groups contains organizers" do
      before { project.stub(:organizers).and_return people_to_mail }
      let(:subject) {  RecepientsBuilder.new(project).from_groups(['organizers']) }

      its(:recepients) { should == [OrganizerRecepient.new(person1), OrganizerRecepient.new(person2)] }
    end

    context "when groups contains conversation_leaders" do
      before { project.stub(:conversation_leaders).and_return people_to_mail }
      let(:subject) {  RecepientsBuilder.new(project).from_groups(['conversation_leaders']) }

      its(:recepients) { should == [ConversationLeaderRecepient.new(person1), ConversationLeaderRecepient.new(person2)] }
    end

    context "when groups contains participants" do
      before { project.stub(:participants).and_return people_to_mail }
      let(:subject) {  RecepientsBuilder.new(project).from_groups(['participants']) }

      its(:recepients) { should == [ParticipantRecepient.new(person1), ParticipantRecepient.new(person2)] }
    end

    context "when groups contains something silly" do
      let(:subject) {  RecepientsBuilder.new(project).from_groups(['bogusgroup']) }

      its(:recepients) { should be_empty }
    end

    context "when groups is nil" do
      let(:subject) {  RecepientsBuilder.new(project).from_groups(nil) }

      its(:recepients) { should be_empty }
    end

  end
end

describe RecepientList do
  describe "send_message" do
    let(:message) { Message.new }
    let(:postman) { Postman }
    let(:project) { stub(Project, coordinators: [a_person_with_email('e@mail.com')], organizers: [a_person_with_email('f@mail.com')]) }

    it "sends it to its list of recepients" do
      recepientlist = RecepientsBuilder.new(project).from_groups ['coordinators', 'organizers']
      recepientlist.recepients[0].should_receive(:send_message).with(message, postman)
      recepientlist.recepients[1].should_receive(:send_message).with(message, postman)
      recepientlist.send_message(message, postman)
    end
  end

  def a_person_with_email(email)
    Account.new(email: email)
  end
end

describe Recepient do
  let(:message) { MailingMessage.new } 
  let(:postman) { mock Postman } 
  shared_examples_for("a_recepient") do
    describe "send_message" do
      it "sends the message to the postman" do
        postman.should_receive(:deliver).with(:mailing_message, message, recepient.person)
        recepient.send_message(message, postman)
      end
    end
  end

  describe CoordinatorRecepient do
    let(:recepient) { CoordinatorRecepient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recepient")
  end

  describe OrganizerRecepient do
    let(:recepient) { OrganizerRecepient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recepient")
  end

  describe ConversationLeaderRecepient do
    let(:recepient) { ConversationLeaderRecepient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recepient")
  end

  describe ParticipantRecepient do
    let(:recepient) { ParticipantRecepient.new(Person.new(:email => 'e@mail.com')) }
    it_should_behave_like("a_recepient")
  end
end
