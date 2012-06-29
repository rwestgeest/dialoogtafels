require 'spec_helper'

describe LocationTodo do

  it { should validate_presence_of :name }

  it_should_behave_like 'a_scoped_object', :location_todo

  context "with tenant scope" do
    prepare_scope :tenant
    describe 'progress' do
      let(:project) { Tenant.current.active_project }
      let(:location_todo) { FactoryGirl.create :location_todo, :project => project }

      context('without_locations') do
        it "is always 100%" do
          location_todo.progress.should == 100
        end
      end

      context('with_locations') do
        let!(:location1) { FactoryGirl.create :location }
        let!(:location2) { FactoryGirl.create :location }
        it "is 0 at first" do
          location_todo.progress.should == 0
        end
        it "is 100 when all done" do
          location1.tick_done(location_todo.id)
          location2.tick_done(location_todo.id)
          location_todo.reload
          location_todo.progress.should == 100
        end
        it "is 50% when half done" do
          location1.tick_done(location_todo.id)
          location_todo.reload
          location_todo.progress.should == 50
        end
      end
    end
  end
end
