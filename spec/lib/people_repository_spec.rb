require 'spec_helper'
require 'people_repository'

class DateRange  < Struct.new(:start_date, :end_date)
end

describe PeopleRepository do
  prepare_scope :tenant
  let(:current_tenant) { Tenant.current } 
  let(:project)    { current_tenant.active_project }
  let!(:conversation) { FactoryGirl.create :conversation } 
  let!(:location) { conversation.location }
  let!(:coordinator) { FactoryGirl.create :coordinator_account }  
  let!(:organizer) { location.organizer } 
  let!(:conversation_leader) { FactoryGirl.create :conversation_leader, conversation: conversation }
  let!(:participant) { FactoryGirl.create :participant, conversation: conversation }

  context "without date range" do
    let(:subject) { PeopleRepository.new(project) }

    its(:coordinators) { should include(coordinator) } 

    its(:organizers) { should == [ organizer ] }

    its(:conversation_leaders) { should == [ conversation_leader ] }

    its(:participants) { should == [ participant ] }
  end

  context "with date range" do
    let(:start_date) { Date.today }
    let(:end_date) { Date.today }
    let(:subject) { PeopleRepository.new(project).for_date_range(start_date, end_date) }

    context "when conversation falls before the date_range" do
      before { conversation.update_attribute :start_date, start_date.yesterday } 
      its(:coordinators) { should include(coordinator) } 
      its(:organizers)   { should == [] }
      its(:conversation_leaders)   { should == [] }
      its(:participants)   { should == [] }
    end

    context "when conversation falls after the date_range" do
      before { conversation.update_attribute :start_date, end_date.tomorrow } 
      its(:coordinators) { should include(coordinator) } 
      its(:organizers)   { should == [] }
      its(:conversation_leaders)   { should == [] }
      its(:participants)   { should == [] }
    end

    context "when conversation is within the date_range" do
      before { conversation.update_attribute :start_date, start_date } 
      its(:coordinators) { should include(coordinator) } 
      its(:organizers)   { should == [organizer] }
      its(:conversation_leaders)   { should == [conversation_leader] }
      its(:participants)   { should == [participant] }
    end
  end

end
