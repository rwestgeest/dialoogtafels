require 'spec_helper'
require 'mailing'

describe RecipientsBuilder do
  let(:people_repository) { stub(PeopleRepository) }
  let(:people_to_mail) { [person1, person2] }
  let(:person1) { Account.new(email: "one@mail.com") }
  let(:person2) { Account.new(email: "two@mail.com") }
  let(:recipients_builder) { RecipientsBuilder.new(people_repository) }


  describe "from_groups" do
    let(:subject) { recipient_list }
    context "when groups contains coordinators" do
      before { people_repository.stub(:coordinators).and_return people_to_mail }
      let(:recipient_list) { recipients_builder.from_groups(['coordinators']) }

      its(:recipients) { should == [CoordinatorRecipient.new(person1), CoordinatorRecipient.new(person2)] }
    end

    context "when groups contains organizers" do
      let(:organizer_with_location) { Organizer.new }
      let(:organizer_without_location) { Organizer.new } 
      before do
         people_repository.stub(:organizers).and_return [organizer_with_location, organizer_without_location]
         organizer_with_location.locations << Location.new
      end
      let(:recipient_list) { recipients_builder.from_groups(['organizers']) }

      its(:recipients) { should include     OrganizerRecipient.new(organizer_with_location) }
      its(:recipients) { should_not include OrganizerRecipient.new(organizer_without_location) }
    end

    context "when groups contains conversation_leaders" do
      before { people_repository.stub(:conversation_leaders).and_return people_to_mail }
      let(:recipient_list) { recipients_builder.from_groups(['conversation_leaders']) }

      its(:recipients) { should == [ConversationLeaderRecipient.new(person1), ConversationLeaderRecipient.new(person2)] }
    end

    context "when groups contains participants" do
      before { people_repository.stub(:participants).and_return people_to_mail }
      let(:recipient_list) { recipients_builder.from_groups(['participants']) }

      its(:recipients) { should == [ParticipantRecipient.new(person1), ParticipantRecipient.new(person2)] }
    end

    context "when groups contains something silly" do
      let(:subject) {  RecipientsBuilder.new(people_repository).from_groups(['bogusgroup']) }

      its(:recipients) { should be_empty }
    end

    context "when groups is nil" do
      let(:subject) {  RecipientsBuilder.new(people_repository).from_groups(nil) }

      its(:recipients) { should be_empty }
    end
  end
end

describe RecipientList do
  describe "send_message" do
    let(:message) { Message.new }
    let(:postman) { Postman }
    let(:coordinator) { Account.new } 
    let(:project) { stub(Project, coordinators: [coordinator], organizers: [organizer]) }

    it "sends it to its list of recipients" do
      recipientlist = RecipientsBuilder.new(project).from_groups ['coordinators', 'organizers']
      recipientlist.recipients[0].should_receive(:send_message).with(message, postman)
      recipientlist.recipients[1].should_receive(:send_message).with(message, postman)
      recipientlist.send_message(message, postman)
    end
  end

  def organizer
    organizer = Organizer.new
    organizer.locations << Location.new
    organizer
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

