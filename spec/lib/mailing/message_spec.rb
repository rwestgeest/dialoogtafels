require 'spec_helper'
require 'mailing'


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

