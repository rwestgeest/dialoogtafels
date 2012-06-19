require 'spec_helper'

describe Training  do
  it_should_behave_like 'a_scoped_object', :training
  it { should validate_presence_of :name }
  it { should validate_presence_of :location }
  it { should validate_presence_of :max_participants }
  it { should validate_numericality_of :max_participants }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :start_time }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :end_time }

  context "with tenant scope" do
    prepare_scope :tenant


    describe "setting start date and start time_" do
      it_should_behave_like "schedulable", :start_date, :start_time do
        def create_schedulable(attrs = {}) 
          Training.new(attrs)
        end
      end
    end

    describe "setting end date and end time_" do
      it_should_behave_like "schedulable", :end_date, :end_time do
        def create_schedulable(attrs = {}) 
          Training.new(attrs)
        end
      end
    end

    describe "creating a training" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :training 
        Training.last.project.should == Tenant.current.active_project
      end
    end

  end

end
