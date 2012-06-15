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

    shared_examples_for "setting_date_and_time" do |date_attr, time_attr|
      let(:time) { Time.now }
      let(:date) { Date.tomorrow }

      it "should let start_date override the date_component in start_time when start_time is set first" do
        conversation = Conversation.location(time_attr => time, date_attr => date, :location => location)
        conversation.reload
        conversation.send(time_attr).should be_within(1.minute).of(time + 1.days)
        conversation.send(date_attr).should == date
      end

      it "should let start_date override the date_component in start_time when start_date is set first" do
        conversation = Conversation.create(date_attr => date, time_attr => time, :location => location)
        conversation.reload
        conversation.send(time_attr).should be_within(1.minute).of(time + 1.days)
        conversation.send(date_attr).should == date
      end

      it "can be done with string values" do
        conversation = Conversation.create(time_attr => I18n.l(time, :format => :long), date_attr => I18n.l(date), :location => location)
        conversation.reload
        conversation.send(time_attr).should be_within(1.minute).of(time + 1.days)
        conversation.send(date_attr).should == date
      end

    end

    describe "setting start date and start time" do
      let(:location) {FactoryGirl.create :location} 
      it_should_behave_like "schedulable", :start_date, :start_time do
        def create_schedulable(attrs)
          Conversation.create(attrs.merge, :location => location)
        end
      end
    end

    describe "setting end date and end time" do
      let(:location) {FactoryGirl.create :location} 
      it_should_behave_like "schedulable", :end_date, :end_time do
        def create_schedulable(attrs)
          Conversation.create(attrs.merge, :location => location)
        end
      end
    end
  end

end
