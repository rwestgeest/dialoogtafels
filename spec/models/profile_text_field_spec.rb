require 'spec_helper'

describe ProfileTextField do
  it_should_behave_like 'a_scoped_object', :profile_text_field
  it { should validate_presence_of :label }
end
