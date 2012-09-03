require 'spec_helper'

describe Participant do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_participant) { FactoryGirl.create :participant } 
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :person }
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
    it { should validate_presence_of :conversation } 
  end

  it_should_behave_like 'a_scoped_object', :participant

  context "with current tenant" do
    prepare_scope :tenant

    it_should_behave_like "creating_a_contributor", Participant do
      before(:all) { @conversation = FactoryGirl.create :conversation }
      def create_contributor(extra_attributes = {})
        begin
        FactoryGirl.create :participant, { :conversation => @conversation }.merge(extra_attributes)
        rescue ActiveRecord::RecordInvalid => e
          p e.record.errors
          raise e
        end
      end
    end

    describe "creating a participant" do
      context "when participant exists for the same location" do
        let!(:existing_participant) { FactoryGirl.create :participant } 
        it "fails" do 
          new_participant = Participant.new(:email => existing_participant.email, :conversation => existing_participant.conversation)
          new_participant.should_not be_valid
          new_participant.errors[:email].should include(I18n.t('activerecord.errors.models.participant.attributes.email.existing'))
        end
      end
      context "when conversation_leader exists for the same location" do
        let!(:existing_conversation_leader) { FactoryGirl.create :conversation_leader } 
        it "fails" do 
          new_participant = Participant.new(:email => existing_conversation_leader.email, :conversation => existing_conversation_leader.conversation)
          new_participant.should_not be_valid
          new_participant.errors[:email].should include(I18n.t('activerecord.errors.models.participant.attributes.email.existing'))
        end
      end
    end
  end
end

