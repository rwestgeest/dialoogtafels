require 'spec_helper'

describe MailingMessage do
  it { should validate_presence_of :reference }

  it_should_behave_like 'a_scoped_object', :mailing_message

  it_should_behave_like "a_message" do
    def a_message(attributes = {})
      MailingMessage.new(attributes)
    end
  end

end
