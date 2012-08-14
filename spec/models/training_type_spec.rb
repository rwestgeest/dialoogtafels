require 'spec_helper'

describe TrainingType  do
  it_should_behave_like 'a_scoped_object', :training_type
  it { should validate_presence_of :name }
  it { should validate_presence_of :project }

  context "with tenant scope" do
    prepare_scope :tenant
    describe "creating a training" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :training 
        Training.last.project.should == Tenant.current.active_project
      end
    end
  end
end
