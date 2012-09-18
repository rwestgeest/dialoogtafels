require 'spec_helper'

describe ProfileFieldValue do
  it_should_behave_like 'a_scoped_object', :profile_field_value
  it { should validate_presence_of :person }
  it { should validate_presence_of :profile_field }
end

