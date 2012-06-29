require 'spec_helper'

describe TrainingInvitation do
  it { should validate_presence_of :reference }

  it_should_behave_like 'a_scoped_object', :location_comment

  it_should_behave_like "a_message" do
    def a_message(attributes = {})
      TrainingInvitation.new(attributes)
    end
  end

  describe "notifications", :focus =>true do
    let(:reference) { FactoryGirl.create :training }
    it_should_behave_like "a_message_notifier", TrainingInvitation, :schedule_training_invitation 


    def create_messaage_from(author, addressee_id_list = [], parent_comment = nil)
      comment = FactoryGirl.build(:training_invitation, :subject => "subject", :reference_id => reference.id, :author => author, :parent => parent_comment)
      comment.set_addressees(addressee_id_list)
      comment.save!
      comment
    end

  end
end
