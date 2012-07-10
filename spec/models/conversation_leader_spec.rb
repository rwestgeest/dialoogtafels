require 'spec_helper'

describe ConversationLeader, :focus => true do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_conversation_leader) { FactoryGirl.create :conversation_leader } 
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :person }
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
    it { should validate_presence_of :conversation } 
  end

  it_should_behave_like 'a_scoped_object', :conversation_leader


  context "with current tenant" do
    prepare_scope :tenant

    it_should_behave_like "creating_a_contributor", ConversationLeader do
      before(:all) { @conversation = FactoryGirl.create :conversation }
      def create_contributor(extra_attributes = {})
        FactoryGirl.create :conversation_leader, { :conversation => @conversation }.merge(extra_attributes)
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

