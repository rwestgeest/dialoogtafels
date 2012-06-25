require 'spec_helper'

describe Postman do
  describe "schedule_message_notification" do
    let(:message) {"message"}
    let(:addressee) { "message" } 
    it "delivers a notification" do
      message_instance = mock('message_instance')
      Notifications.should_receive(:send).with(:new_comment, message, addressee).and_return message_instance
      message_instance.should_receive :deliver
      Postman.schedule_message_notification(message, addressee)
    end
  end
end
