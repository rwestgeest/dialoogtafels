require 'spec_helper'

describe ConversationLeader do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_conversation_leader) { FactoryGirl.create :conversation_leader } 
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :person }
    it { should_not allow_value(existing_conversation_leader.email).for(:email) }
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
    it { should validate_presence_of :conversation } 
  end

  it_should_behave_like 'a_scoped_object', :conversation_leader

  context "with current tenant" do
    prepare_scope :tenant

    describe "creating a conversation_leader" do
      let!(:conversation) { FactoryGirl.create :conversation }

      def create_conversation_leader
        FactoryGirl.create :conversation_leader, :conversation => conversation
      end

      it "associates it for the tenants active project" do
        create_conversation_leader
        ConversationLeader.last.project.should == Tenant.current.active_project
      end

      it "creates an person" do
        expect{ create_conversation_leader }.to change(Person, :count).by(1)
        ConversationLeader.last.person.should == Person.last
      end

      it "creates a worker account with role conversation_leader" do
        expect{ create_conversation_leader }.to change(Account, :count).by(1)
        Account.last.person.should == Person.last
      end

      it "sends a welcome message" do
        Postman.should_receive(:deliver).with(:account_welcome, an_instance_of(TenantAccount))
        create_conversation_leader
      end
    end

    describe "register_for training" do
      let(:training) { FactoryGirl.create :training } 
      let(:training_id) { training.id }
      let(:conversation_leader) { FactoryGirl.create :conversation_leader }

      describe "adding one" do

        it "adds the conversation_leader it to the attendee list" do
          conversation_leader.register_for(training_id)
          training.attendees == [conversation_leader]
        end 
        it "creates a registration instance " do
          expect { 
            conversation_leader.register_for(training_id)
          }.to change(TrainingRegistration, :count).by(1)
          TrainingRegistration.last.attendee.should == conversation_leader
          TrainingRegistration.last.training.should == training
        end 
        it "adds the training to the attendees training list" do
          conversation_leader.register_for(training_id)
          conversation_leader.should have(1).trainings
        end

        it "returns the added training" do
          conversation_leader.register_for(training_id).should == training
        end

        context  "when training not found" do
          it "returns nil" do
            conversation_leader.register_for("bogus").should be_nil
          end
        end

      end

      describe "removing one" do
        before { conversation_leader.register_for(training_id) }
        it "destroys the traiing registration instance" do
          expect { conversation_leader.cancel_registration_for(training_id) }.to change(TrainingRegistration, :count).by(-1)
        end

        it "returns the added training" do
          conversation_leader.cancel_registration_for(training_id).should == training
        end

        context  "when training not found" do
          it "does not change the registration count" do
            expect { conversation_leader.cancel_registration_for("bogus") }.not_to change(TrainingRegistration, :count)
          end
          it "returns nil" do
            conversation_leader.cancel_registration_for("bogus").should be_nil
          end
        end

        context  "when training exists but not registered for" do
          let!(:other_training) { FactoryGirl.create :training }

          it "does not change the registration count" do
            expect { conversation_leader.cancel_registration_for(other_training.id) }.not_to change(TrainingRegistration, :count)
          end

          it "returns nil" do
            conversation_leader.cancel_registration_for(other_training.id).should be_nil
          end
        end

      end
    end
  end
end

