require 'spec_helper'

describe ProfileSelectionField do
  it_should_behave_like 'a_scoped_object', :profile_selection_field
  it { should validate_presence_of :label }
  it { should validate_presence_of :values }
end

