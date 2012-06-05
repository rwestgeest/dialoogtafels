require 'spec_helper'

describe Project do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :tenant }
  end

  it_should_behave_like 'a_scoped_object', :project

  context "with tenant scope" do
    describe "defaults" do 
      subject { Project.new }
      its(:start_time) { should be_within(1).of(Time.now) }
      its(:start_date) { should == Date.today }
    end
  end

end
