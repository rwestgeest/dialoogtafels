require 'spec_helper'

describe Project do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :tenant }
  end

  it_should_behave_like 'a_scoped_object', :project, :tenant
end
