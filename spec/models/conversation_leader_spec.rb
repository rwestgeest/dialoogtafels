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
  end
end

