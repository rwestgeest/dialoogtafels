require 'spec_helper'

describe LocationComment do
  it { should validate_presence_of :reference }

  it_should_behave_like 'a_scoped_object', :location_comment

  it_should_behave_like "a_message" do
    def a_message(attributes = {})
      LocationComment.new(attributes)
    end
  end

  describe "notifications" do
    it_should_behave_like "a_message_notifier", LocationComment, :schedule_message_notification do
      let(:reference) { FactoryGirl.create :location }

      def create_messaage_from(author, addressee_id_list = [], parent_comment = nil)
        comment = FactoryGirl.build(:location_comment, :subject => "subject", :reference_id => reference.id, :author => author, :parent => parent_comment)
        comment.set_addressees(addressee_id_list)
        comment.save!
        comment
      end
    end
  end

end
