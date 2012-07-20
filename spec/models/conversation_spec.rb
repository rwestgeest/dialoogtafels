require 'spec_helper'

describe Conversation do
  it_should_behave_like 'a_scoped_object', :conversation

  it { should validate_presence_of :start_date }
  it { should validate_presence_of :start_time }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :end_time }


  context "with tenant scope" do
    prepare_scope :tenant
    describe "defaults" do
      let!(:conversation) { Conversation.new :location => FactoryGirl.create(:location) } 
      let!(:project)  { conversation.location.project }
      subject { conversation } 
      its(:default_length) { should == project.conversation_length }
      its(:start_date) { should == project.start_time.to_date }
      its(:start_time) { should be_within(1).of(project.start_time) }
      its(:end_date) { should == conversation.start_date } 
      its(:end_time) { should be_within(1).of(conversation.start_time + project.conversation_length.minutes) } 
    end

    describe "destroying a conversation" do
      let!(:conversation) { FactoryGirl.create :conversation } 
      let!(:participant) { FactoryGirl.create :participant, conversation: conversation  } 
      let!(:conversation_leader) { FactoryGirl.create :conversation_leader, conversation: conversation } 
      it "destroys the associating participants" do
        expect { conversation.destroy }.to change(Participant, :count).by(-1)
        Participant.should_not be_exist(participant.id)
      end
      it "destroys the associating conversation_leaders" do
        expect { conversation.destroy }.to change(ConversationLeader, :count).by(-1)
        ConversationLeader.should_not be_exist(conversation_leader.id)
      end
    end

    describe "setting start date and start time" do
      let(:location) {FactoryGirl.create :location} 
      it_should_behave_like "schedulable", :start_date, :start_time do
        def create_schedulable(attrs = {})
          Conversation.new(attrs.merge :location => location)
        end
      end
    end

    describe "setting end date and end time" do
      let(:location) {FactoryGirl.create :location} 
      it_should_behave_like "schedulable", :end_date, :end_time do
        def create_schedulable(attrs = {})
          Conversation.new(attrs.merge :location => location)
        end
      end
    end
    describe "full" do 
      let( :location ) { Location.new project: project }
      let( :project ) { Project.new max_participants_per_table: 8 }
      let( :conversation ) { Conversation.new location: location, number_of_tables: 2 }
      subject { conversation }

      context "for leader" do
        it { should_not be_leaders_full }
        it "is full when leader equals number of tables" do
          conversation.conversation_leader_count = conversation.number_of_tables
          conversation.should be_leaders_full
        end
        it "is full when leaders exceed  number of tables" do
          conversation.conversation_leader_count = conversation.number_of_tables + 1
          conversation.should be_leaders_full
        end
      end
      context 'for participant' do
      it { should_not be_participants_full }
        it "is full when participant equals number of tables * max_participants per table" do
          conversation.participant_count = conversation.number_of_tables * project.max_participants_per_table 
          conversation.should be_participants_full
        end
        it "is full when participants exceed  number of tables" do
          conversation.participant_count = conversation.number_of_tables * project.max_participants_per_table + 1
          conversation.should be_participants_full
        end
      end
    end
  end

end
