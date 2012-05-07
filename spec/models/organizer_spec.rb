require 'spec_helper'

describe Organizer do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
  end
  it_should_behave_like 'a_scoped_object', :organizer, :tenant

end
