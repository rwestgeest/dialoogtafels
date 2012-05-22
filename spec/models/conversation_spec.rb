require 'spec_helper'

describe Conversation do
  it_should_behave_like 'a_scoped_object', :conversation

  it { should validate_presence_of :start_date }
  it { should validate_presence_of :start_time }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :end_time }

end
