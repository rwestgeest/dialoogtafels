require 'spec_helper'

describe Person do
  it_should_behave_like 'a_scoped_object', :person, :tenant

end
