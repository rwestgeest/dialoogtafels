require 'spec_helper'

describe Participant do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_participant) { FactoryGirl.create :participant } 
    it { should_not validate_presence_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :person }
    it { should_not allow_value(existing_participant.email).for(:email) }
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
    it { should validate_presence_of :conversation } 
  end

  it_should_behave_like 'a_scoped_object', :participant

  context "with current tenant" do
    prepare_scope :tenant

    describe "creating an participant" do
      let!(:conversation) { FactoryGirl.create :conversation }

      def create_participant
        FactoryGirl.create :participant, :conversation => conversation
      end

      it "associates it for the tenants active project" do
        create_participant
        Participant.last.project.should == Tenant.current.active_project
      end

      it "creates an person" do
        expect{ create_participant }.to change(Person, :count).by(1)
        Participant.last.person.should == Person.last
      end

      it "creates a worker account with role participant" do
        expect{ create_participant }.to change(Account, :count).by(1)
        Account.last.person.should == Person.last
      end

      it "sends a welcome message" do
        Postman.should_receive(:deliver).with(:account_welcome, an_instance_of(TenantAccount))
        create_participant
      end
    end
    describe "save_with_notification" do
      let!(:conversation) { FactoryGirl.create :conversation }
      let(:participant) { FactoryGirl.build :participant, :conversation => conversation }
      it "saves the participant" do
        expect { participant.save_with_notification }.to change(Participant, :count).by(1)
      end
      it "sends a notification" do
        Postman.stub(:deliver).with(:account_welcome, an_instance_of(TenantAccount))
        Postman.should_receive(:deliver).with(:new_participant,an_instance_of(Participant))
        participant.save_with_notification
      end
      it "does not send when save fails" do
        Postman.should_not_receive(:deliver).with(:new_participant,an_instance_of(Participant))
        participant.name = ''
        participant.save_with_notification
      end
    end
  end
end

