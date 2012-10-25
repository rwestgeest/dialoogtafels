require 'spec_helper'
require 'people_repository'

describe PeopleRepository do
  prepare_scope :tenant
  let(:current_tenant) { Tenant.current } 
  let(:project)    { current_tenant.active_project }
  let(:subject) { PeopleRepository.new(project) }
  
  let(:coordinator) { FactoryGirl.create :coordinator_account }  
  its(:coordinators) { should include(coordinator) } 

  let(:organizer) { FactoryGirl.create :organizer }
  its(:organizers) { should == [ organizer ] }

  let(:conversation_leader) { FactoryGirl.create :conversation_leader }
  its(:conversation_leaders) { should == [ conversation_leader ] }

  let(:participant) { FactoryGirl.create :participant }
  its(:participants) { should == [ participant ] }
end
