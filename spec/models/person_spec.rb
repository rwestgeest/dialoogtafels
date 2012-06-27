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

    describe "profile value" do
      let!(:age_field) { FactoryGirl.create :profile_string_field, :field_name => 'age' }
      let(:person) { FactoryGirl.create :person }
     
      describe "setting through mass assignment" do 
        it "adds a profile value instance for the profile field" do
          expect { person.update_attributes :profile_age => "66" }.to change(ProfileFieldValue, :count).by(1)
        end
        it "ignores value of nil" do
          expect { person.update_attributes :profile_age => nil }.not_to change(ProfileFieldValue, :count)
        end
        it "ignores value of empty" do
          expect { person.update_attributes :profile_age => "" }.not_to change(ProfileFieldValue, :count)
        end
        context "when field is not available" do
          it "raises a rails compatible error" do
            expect { person.update_attributes :profile_country => "Kuwait" }.to raise_exception ActiveRecord::UnknownAttributeError
          end
        end 
        context "when value exists" do
          before {person.update_attributes :profile_age => "55"} 
          it "removes the field value when set to empty" do
            expect { person.update_attributes :profile_age => "" }.to change(ProfileFieldValue, :count).by(-1)
          end
          it "removes the field value when set to nil" do
            expect { person.update_attributes :profile_age => nil }.to change(ProfileFieldValue, :count).by(-1)
          end
          it "does not change the number of values when changed" do
            expect { person.update_attributes :profile_age => "66" }.not_to change(ProfileFieldValue, :count)
            person.profile_age.should == "66"
          end
        end
      end

      describe "getting" do
        it "returns the value when set" do
          person.update_attributes :profile_age => "66"
          person.profile_age.should == "66"
        end
        it "returns nil when not set" do
          person.profile_age.should be_nil
        end
        context "when field is not available" do
          it "raisses a rails compatible error" do
            expect { person.profile_country }.to raise_exception NoMethodError
          end
        end 
        context "before type case" do
          it "returns the value when set" do
            person.update_attributes :profile_age => "66"
            person.profile_age_before_type_cast.should == "66"
          end
          it "returns nil when not set" do
            person.profile_age_before_type_cast.should be_nil
          end
        end
      end
    end

    describe "contributions for project" do
      let(:person) { FactoryGirl.create(:person) }
      let(:project) { Tenant.current.active_project }
      let(:conversation) { FactoryGirl.create :conversation }
      let(:location) { conversation.location }

      it "contains the contributor for the project provided" do
        conversation_leader = create_conversation_leader(person, project, conversation)
        person.active_contributions_for(project).should == [conversation_leader]
      end

      it "contains more contributors if available" do
        conversation_leader = create_conversation_leader(person, project, conversation)
        participant = create_participant(person, project, conversation)
        person.active_contributions_for(project).should == [conversation_leader, participant]
      end

      it "contains contributors for more conversation if available" do
        conversation_leader = create_conversation_leader(person, project, FactoryGirl.create(:conversation))
        participant = create_participant(person, project, conversation)
        person.active_contributions_for(project).should == [conversation_leader, participant]
      end

      it "does not contain contributions for another project" do
        other_project = FactoryGirl.create(:project)
        conversation_leader = create_conversation_leader(person, other_project, conversation)
        person.active_contributions_for(project).should == []
      end

      it "does not contain contributions where i am organizer" do
        create_organizer(person, project)
        person.active_contributions_for(project).should == []
      end 

      def create_organizer(person, project)
        create_contributor(Organizer, person, project, nil)
      end
      def create_participant(person, project, conversation)
        create_contributor(Participant, person, project, conversation)
      end

      def create_conversation_leader(person, project, conversation)
        create_contributor(ConversationLeader, person, project, conversation)
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
  end
end
