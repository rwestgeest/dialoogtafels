require 'spec_helper'

describe ProfileStringField do
  it_should_behave_like 'a_scoped_object', :profile_string_field
  it { should validate_presence_of :label }
end
