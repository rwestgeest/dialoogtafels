require 'spec_helper'

describe Participant do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_participant) { FactoryGirl.create :participant } 
    it { should_not validate_presence_of :email }
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
        FactoryGirl.create :participant, { :conversation => @conversation }.merge(extra_attributes)
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
        Postman.should_receive(:deliver).
          with(:new_participant,
              an_instance_of(Participant),
              conversation.organizer)
        participant.save_with_notification
      end
      it "does not send when save fails" do
        Postman.should_not_receive(:deliver)
        participant.name = ''
        participant.save_with_notification
      end
    end
  end
end

