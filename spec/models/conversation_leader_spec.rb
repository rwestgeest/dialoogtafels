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

      def create_conversation_leader(extra_attributes = {})
        FactoryGirl.create :conversation_leader, { :conversation => conversation }.merge(extra_attributes)
      end

      it "associates it for the tenants active project" do
        create_conversation_leader
        ConversationLeader.last.project.should == Tenant.current.active_project
      end

      it "associates it for the project given if provided" do
        project = FactoryGirl.create :project
        create_conversation_leader :project => project
        ConversationLeader.last.project.should == project
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

    describe "save_with_notification" do
      let!(:conversation) { FactoryGirl.create :conversation }
      let(:conversation_leader) { FactoryGirl.build :conversation_leader, :conversation => conversation }
      it "saves the conversation_leader" do
        expect { conversation_leader.save_with_notification }.to change(ConversationLeader, :count).by(1)
      end
      it "sends a notification" do
        Postman.stub(:deliver).with(:account_welcome, an_instance_of(TenantAccount))
        Postman.should_receive(:deliver).
          with(:new_conversation_leader, 
               an_instance_of(ConversationLeader),
               conversation.organizer)
        conversation_leader.save_with_notification
      end
      it "does not send when save fails" do
        Postman.should_not_receive(:deliver)
        conversation_leader.name = ''
        conversation_leader.save_with_notification
      end
    end

  end
end

