require 'spec_helper'

describe TrainingType  do
  it_should_behave_like 'a_scoped_object', :training_type
  it { should validate_presence_of :name }
  it { should validate_presence_of :project }

  context "with tenant scope" do
    prepare_scope :tenant
    describe "creating a training" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :training_type 
        TrainingType.last.project.should == Tenant.current.active_project
      end
    end

    describe "available_trainings" do
      let(:training_type) { FactoryGirl.create :training_type } 

      it "is empty by default" do
        training_type.available_trainings.should be_empty
      end

      context "when a training is present" do
        let!(:training) { FactoryGirl.create :training, training_type: training_type } 

        it "contains that training" do
          training_type.available_trainings.should include(training)
        end

        context "but full" do
          before { Training.update_counters(training, :participant_count => training.max_participants) }
          it "does not contain that training" do
            training_type.available_trainings.should be_empty
          end
        end
      end

    end
  end
end
