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

    describe "destroying a location" do 
      it "destroys the conversations" do
        conversation = FactoryGirl.create :conversation
        expect { conversation.location.destroy }.to change(Conversation, :count).by(-1)
        Conversation.should_not be_exists(conversation.id)
      end
    end

    describe "publisheds" do
      let!(:published) { FactoryGirl.create :location, :published => true }
      let!(:concept) { FactoryGirl.create :location, :published => false }
      subject { Location.publisheds }
      it { should include published }
      it { should_not include concept }
    end

    describe "availables_for_participants" do
      let!(:published) { FactoryGirl.create :location, :published => true }
      let!(:concept) { FactoryGirl.create :location, :published => false }
      subject { Location.availables_for_participants }

      it { should_not include concept }

      describe "when no location contains conversations" do
        it { should_not include published }
      end

      describe "when a location contains conversations" do
        let!(:conversation) { FactoryGirl.create :conversation, location: published }
        it { should include published }
        describe "that are full" do
          before { Conversation.update_counters conversation.id, :participant_count => conversation.location.project.max_participants_per_table } 
          it { should_not include published }
        end
      end
    end

    describe "publisheds_for_conversation_leaders" do
      let!(:published) { FactoryGirl.create :location, :published => true }
      let!(:concept) { FactoryGirl.create :location, :published => false }
      subject { Location.publisheds_for_conversation_leaders }

      it { should_not include concept }

      describe "when no location contains conversations" do
        it { should_not include published }
      end

      describe "when a location contains conversations" do
        let!(:conversation) { FactoryGirl.create :conversation, location: published }
        it { should include published }
        describe "that are full" do
          before { Conversation.update_counters conversation.id, :conversation_leader_count => conversation.number_of_tables }
          it { should_not include published }
        end
      end
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
        fillup(conversation, :conversation_leaders)
        location.available_conversations_for(person).should == [conversation]
      end
      it "contains conversations that have only paricipants full" do
        fillup(conversation, :participants)
        location.available_conversations_for(person).should == [conversation]
      end
      it "contains no conversations that are full" do
        fillup(conversation, :conversation_leaders, :participants)
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
    describe "full?" do
      let(:location) { FactoryGirl.create :location } 
      let(:conversation) { FactoryGirl.create :conversation, location: location }
      alias_method :create_conversation, :conversation

      subject { location } 

      it "is not full without conversations" do
        location.should_not be_full
      end

      it "is not full with non full conversations " do
        create_conversation
        location.should_not be_full 
      end

      it "is full with one full conversaions" do
        fillup(conversation, :conversation_leaders, :participants)
        location.should be_full
      end

      context "with one full conversation" do
        before { fillup(conversation, :conversation_leaders, :participants) }
        let!(:another_conversation) { FactoryGirl.create :conversation, location: location  }

        it "is not full with another non_full conversation" do
          location.should_not be_full
        end

        it "is full with all full conversations" do
          fillup(another_conversation, :conversation_leaders, :participants)
          location.should be_full
        end
      end
    end


    def fillup(conversation, *what_to_fill)
      return unless what_to_fill.include?(:conversation_leaders) || what_to_fill.include?(:participants)
      counters = {}
      counters[:conversation_leader_count] = conversation.max_conversation_leaders if what_to_fill.include?(:conversation_leaders)
      counters[:participant_count] = conversation.max_participants if what_to_fill.include?(:participants)
      Conversation.update_counters conversation.id, counters
    end
  end
end
