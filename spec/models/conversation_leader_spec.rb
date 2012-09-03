require 'spec_helper'

describe ConversationLeader do
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

    describe "creating a conversation_leader" do
      context "when participant exists for the same location" do
        let!(:existing_participant) { FactoryGirl.create :participant } 
        it "fails" do 
          new_participant = ConversationLeader.new(:email => existing_participant.email, :conversation => existing_participant.conversation)
          new_participant.should_not be_valid
          new_participant.errors[:email].should include(I18n.t('activerecord.errors.models.conversation_leader.attributes.email.existing'))
        end
      end
      context "when conversation_leader exists for the same location" do
        let!(:existing_conversation_leader) { FactoryGirl.create :conversation_leader } 
        it "fails" do 
          new_participant = ConversationLeader.new(:email => existing_conversation_leader.email, :conversation => existing_conversation_leader.conversation)
          new_participant.should_not be_valid
          new_participant.errors[:email].should include(I18n.t('activerecord.errors.models.conversation_leader.attributes.email.existing'))
        end
      end
    end
  end
end

