require 'spec_helper'

describe Person do
  it_should_behave_like 'a_scoped_object', :person

  describe "validations" do
    prepare_scope :tenant
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
    it {should validate_presence_of :telephone }
    it {should validate_presence_of :name }
  end

  context "with current tenant" do 
    prepare_scope :tenant

    describe "creating a person" do 
      it "creates an account if email address is supplied" do
        expect{ FactoryGirl.create :person }.to change(Account, :count).by(1)
        Account.last.person.should === Person.last
      end
      it "creates no account if email addres is not supplied" do
        expect{ FactoryGirl.create :person, :email => nil }.to change(Person, :count).by(1)
        expect{ FactoryGirl.create :person, :email => nil }.not_to change(Account, :count).by(1)
      end
    end

    it_should_behave_like "a_profile_field_holder" do
      subject {  FactoryGirl.create :person }
    end

    describe "conversation_contributions for project" do
      let(:person) { FactoryGirl.create(:person) }
      let(:project) { Tenant.current.active_project }
      let(:conversation) { FactoryGirl.create :conversation }
      let(:other_conversation) { FactoryGirl.create :conversation } 
      let(:location) { conversation.location }

      it "contains the contributor for the project provided" do
        conversation_leader = create_conversation_leader(person, project, conversation)
        person.conversation_contributions_for(project).should == [conversation_leader]
      end

      it "contains more contributors if available" do
        conversation_leader = create_conversation_leader(person, project, conversation)
        participant = create_participant(person, project, other_conversation)
        person.conversation_contributions_for(project).should == [conversation_leader, participant]
      end

      it "contains contributors for more conversation if available" do
        conversation_leader = create_conversation_leader(person, project, FactoryGirl.create(:conversation))
        participant = create_participant(person, project, conversation)
        person.conversation_contributions_for(project).should == [conversation_leader, participant]
      end

      it "does not contain contributions for another project" do
        other_project = FactoryGirl.create(:project)
        conversation_leader = create_conversation_leader(person, other_project, conversation)
        person.conversation_contributions_for(project).should == []
      end

      it "does not contain contributions where i am organizer" do
        create_organizer(person, project)
        person.conversation_contributions_for(project).should == []
      end 
    end

    describe "highest_contribution" do
      let(:person) { FactoryGirl.create(:person) }
      let(:project) { Tenant.current.active_project }
      let(:conversation) { FactoryGirl.create :conversation }
      let(:other_conversation) { FactoryGirl.create :conversation }
      let(:location) { conversation.location }
      subject { person.highest_contribution(project) }

      context "when i am conversation_leader" do
        let!(:conversation_leader) { create_conversation_leader(person, project, conversation) }
        it { should == conversation_leader }
        context "and organizer" do
          let!(:organizer) { create_organizer(person, project ) }
          it { should == organizer }
        end
        context "and participant" do
          let!(:participant) { create_participant(person, project, other_conversation) }
          it { should == conversation_leader }
        end
      end

      context "when i am participant" do
        let!(:participant) { create_participant(person, project, conversation) }
        it { should == participant }
      end

      context "when i am organizer" do
        let!(:organizer) { create_organizer(person, project ) }
        it { should == organizer }
      end

      context "for a specific project" do
        let!(:other_project) { FactoryGirl.create :project }
        let!(:conversation_leader) { create_conversation_leader(person, other_project, conversation) }
        it { person.highest_contribution(other_project).should == conversation_leader }
      end
    end

    describe "replace training_registrations" do
      let(:training) { FactoryGirl.create :training } 
      let(:training_id) { training.id }
      let(:person) { FactoryGirl.create :person }
      let(:conversation_leader) { FactoryGirl.create :conversation_leader, person: person }

      it "creates a registration instance" do
        expect {
          person.replace_training_registrations([ training_id ])
        }.to change(TrainingRegistration, :count).by(1)
      end

      it "creates only one registration instance when training is passed multiple times" do
        expect { 
          person.replace_training_registrations [training_id, training_id]
        }.to change(TrainingRegistration, :count).by(1)
      end

      it "ignores illegal training ids" do
        expect { 
          person.replace_training_registrations ["bogus"] 
        }.not_to change(TrainingRegistration, :count)
      end

      context "when registerd for a training" do
        before { person.register_for(FactoryGirl.create :training) }
        
        it "removes existing registrations" do
          expect {
            person.replace_training_registrations([ training_id ])
          }.not_to change(TrainingRegistration, :count)
        end

        it "registers for the new training" do
          person.replace_training_registrations([training_id])
          person.should be_registered_for_training(training_id)
        end
      end

      describe "registering for more trainings" do 
        let!(:other_training) {  FactoryGirl.create :training  }

        it "creates more registration instances" do
          expect { 
            person.replace_training_registrations [training_id, other_training.id]
          }.to change(TrainingRegistration, :count).by(2)
        end
        it "registers for all trainings" do
          person.replace_training_registrations [training_id, other_training.id]
          person.should be_registered_for_training(training_id)
          person.should be_registered_for_training(other_training.id)
        end
      end
    end

    describe "register_for training" do
      let(:training) { FactoryGirl.create :training } 
      let(:training_id) { training.id }
      let(:person) { FactoryGirl.create :person }
      let(:conversation_leader) { FactoryGirl.create :conversation_leader, person: person }

      describe "adding one" do

        it "adds the person it to the attendee list" do
          person.register_for(training_id)
          training.attendees == [person]
        end 

        it "makes it registerd for training" do
          person.register_for(training_id)
          person.should be_registered_for_training(training_id)
        end

        it "creates a registration instance " do
          expect { 
            person.register_for(training_id)
          }.to change(TrainingRegistration, :count).by(1)
          TrainingRegistration.last.attendee.should == person
          TrainingRegistration.last.training.should == training
        end 

        it "cannot register twice for the same training" do
          expect { 
            person.register_for(training_id)
            person.register_for(training_id)
          }.to change(TrainingRegistration, :count).by(1)
        end

        it "creates a registration instance for each training" do
          another_training = FactoryGirl.create :training
          expect {
            person.register_for(training.id) 
            person.register_for(another_training.id) 
          }.to change(TrainingRegistration, :count).by(2)
        end

        it "adds the training to the attendees training list" do
          person.register_for(training_id)
          person.should have(1).trainings
        end

        it "returns the added training" do
          person.register_for(training_id).should == training
        end

        context  "when training not found" do
          it "returns nil" do
            person.register_for("bogus").should be_nil
          end
        end

        context "when the person is destroyed" do
          before { person.register_for(training_id) }
          it "removes the registration" do
            expect { person.destroy }.to change(TrainingRegistration, :count).by(-1)
          end
        end
      end

      describe "removing one" do
        before { person.register_for(training_id) }
        it "destroys the traiing registration instance" do
          expect { person.cancel_registration_for(training_id) }.to change(TrainingRegistration, :count).by(-1)
        end

        it "makes it not registerd for training" do
          person.cancel_registration_for(training_id)
          person.should_not be_registered_for_training(training)
        end

        it "returns the added training" do
          person.cancel_registration_for(training_id).should == training
        end

        context  "when training not found" do
          it "does not change the registration count" do
            expect { person.cancel_registration_for("bogus") }.not_to change(TrainingRegistration, :count)
          end
          it "returns nil" do
            person.cancel_registration_for("bogus").should be_nil
          end
        end

        context  "when training exists but not registered for" do
          let!(:other_training) { FactoryGirl.create :training }

          it "does not change the registration count" do
            expect { person.cancel_registration_for(other_training.id) }.not_to change(TrainingRegistration, :count)
          end

          it "returns nil" do
            person.cancel_registration_for(other_training.id).should be_nil
          end
        end
      end
    end

    describe 'conversation_leaders_for(project)' do
      let(:person) { FactoryGirl.create(:person) }
      let(:project) { Tenant.current.active_project }
      let(:conversation) { FactoryGirl.create :conversation }

      it "contains nothing by default" do
        Person.conversation_leaders_for(project).should == []
      end
      it "contains the person if it plays a converation leader role" do
        create_conversation_leader(person, project, conversation)
        Person.conversation_leaders_for(project).should == [person]
      end
      it "contains the person if it has a conversation_leader_ambition" do
        create_conversation_leader(person, project)
        Person.conversation_leaders_for(project).should == [person]
      end
      it "contains the person once if it plays a converation leader role twice" do
        create_conversation_leader(person, project, FactoryGirl.create(:conversation))
        create_conversation_leader(person, project, conversation)
        Person.conversation_leaders_for(project).should == [person]
      end
      it "excludeds the person if it plays conversation_leader in another project" do
        create_conversation_leader(person, FactoryGirl.create(:project), conversation)
        Person.conversation_leaders_for(project).should == []
      end

      describe "without table" do
        it "should be empty when it has a conversation" do
          create_conversation_leader(person, project, conversation) 
          Person.conversation_leaders_without_table_for(project).should == []
        end
        it "should contain people with only the ambition" do
          create_conversation_leader(person, project, nil) 
          Person.conversation_leaders_without_table_for(project).should == [person]
        end
      end
    end

    describe 'organizers_for(project)' do
      let(:person) { FactoryGirl.create(:person) }
      let(:project) { Tenant.current.active_project }

      it "contains nothing by default" do
        Person.organizers_for(project).should == []
      end

      it "contains the person if it plays a organizer role" do
        create_organizer(person, project)
        Person.organizers_for(project).should == [person]
      end

      it "contains all peiple that play an organizer role" do
        other_person = FactoryGirl.create(:person)
        create_organizer(person, project)
        create_organizer(other_person, project)
        Person.organizers_for(project).should include(person)
        Person.organizers_for(project).should include(other_person)
      end
    end

    describe 'participants_for(project)' do
      let(:person) { FactoryGirl.create(:person) }
      let(:project) { Tenant.current.active_project }
      let(:conversation) { FactoryGirl.create :conversation }

      it "contains nothing by default" do
        Person.participants_for(project).should == []
      end
      it "contains the person if it plays a converation leader role" do
        create_participant(person, project, conversation)
        Person.participants_for(project).should == [person]
      end
      it "contains the person if it has a participant_ambition" do
        create_participant(person, project)
        Person.participants_for(project).should == [person]
      end
      it "contains the person once if it plays a converation leader role twice" do
        create_participant(person, project, FactoryGirl.create(:conversation))
        create_participant(person, project, conversation)
        Person.participants_for(project).should == [person]
      end
      it "excludeds the person if it plays participant in another project" do
        create_participant(person, FactoryGirl.create(:project), conversation)
        Person.participants_for(project).should == []
      end

      describe "without table" do
        it "should be empty when it has a conversation" do
          create_participant(person, project, conversation) 
          Person.participants_without_table_for(project).should == []
        end
        it "should contain people with only the ambition" do
          create_participant(person, project, nil) 
          Person.participants_without_table_for(project).should == [person]
        end
      end
    end
  end

  def create_organizer(person, project)
    create_contributor(Organizer, person, project, nil)
  end

  def create_participant(person, project, conversation = nil)
    create_contributor(ParticipantAmbition, person, project, nil) rescue ActiveRecord::RecordInvalid # ignore 
    create_contributor(Participant, person, project, conversation) if conversation
  end

  def create_conversation_leader(person, project, conversation = nil)
    create_contributor(ConversationLeaderAmbition, person, project, nil) rescue ActiveRecord::RecordInvalid # ignore 
    create_contributor(ConversationLeader, person, project, conversation) if conversation
  end

  def create_contributor(contributor_class, person, project, conversation)
    contributor = contributor_class.new
    contributor.person = person
    contributor.project = project
    contributor.conversation = conversation if conversation
    contributor.save!
    contributor
  end
end
