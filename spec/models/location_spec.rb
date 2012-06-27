require 'spec_helper'

describe Location do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_organizer) { FactoryGirl.create :locations } 
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :postal_code }
    it { should validate_presence_of :city }
    it { should validate_presence_of :organizer }
    it { should have_many :conversations }
  end

  it_should_behave_like 'a_scoped_object', :location

  context "with current tenant" do
    prepare_scope :tenant

    describe "a new location" do
      it "should have the tenants name as city by default " do  
        Location.new.city.should == Tenant.current.name 
      end
      it "'s city can be overridden" do  
        Location.new(:city => "rotterdam").city.should == "rotterdam"
      end
    end
    describe "creating an location" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :location 
        Location.last.project.should == Tenant.current.active_project
      end
    end

    describe "publisheds" do
      let!(:published) { FactoryGirl.create :location, :published => true }
      let!(:concept) { FactoryGirl.create :location, :published => false }
      subject { Location.publisheds }
      it { should include published }
      it { should_not include concept }
    end

    describe 'involveds' do
      attr_reader :location, :conversation1, :conversation2
      before(:all) do
        @location = FactoryGirl.create :location
        @conversation1 = FactoryGirl.create :conversation, location: location
        @conversation2 = FactoryGirl.create :conversation, location: location
      end
      describe 'conversation leaders' do
        it "contains conversation leaders of all conversations" do
          leader1 = FactoryGirl.create(:conversation_leader, conversation: conversation1)
          leader2 = FactoryGirl.create(:conversation_leader, conversation: conversation2)
          @location.conversation_leaders.should == [leader1, leader2]
        end
        it "contains participants of all conversations" do
          participant1 = FactoryGirl.create(:participant, conversation: conversation1)
          participant2 = FactoryGirl.create(:participant, conversation: conversation2)
          @location.participants.should == [participant1, participant2]
        end
      end
    end

    describe 'available_conversations_for(person)' do
      let(:location) { FactoryGirl.create :location }
      let!(:conversation) { FactoryGirl.create :conversation, :location => location }
      let(:person) { FactoryGirl.create :person }
      it "containes all conversations if person has not been registered" do
        location.available_conversations_for(person).should == [conversation]
      end
      it "contains conversations that have only conversation leaders full" do
        Conversation.update_counters conversation.id, 
                                    :conversation_leader_count => conversation.max_conversation_leaders 
        location.available_conversations_for(person).should == [conversation]
      end
      it "contains conversations that have only paricipants full" do
        Conversation.update_counters conversation.id, 
                                    :participant_count => conversation.max_participants
        location.available_conversations_for(person).should == [conversation]
      end
      it "contains no conversations that are full" do
        Conversation.update_counters conversation.id, 
                                    :conversation_leader_count => conversation.max_conversation_leaders, 
                                    :participant_count => conversation.max_participants
        location.available_conversations_for(person).should == []
      end
      it "contains no conversations where person plays conversation leader" do
        ConversationLeader.create! conversation:  conversation , :person => person
        location.available_conversations_for(person).should == []
      end
      it "contains no conversations where person plays participant" do
        Participant.create! conversation:  conversation , :person => person
        location.available_conversations_for(person).should == []
      end
    end
  end
end
