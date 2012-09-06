require 'spec_helper'

describe Project, focus:true do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :conversation_length }
    it { should validate_numericality_of :conversation_length }
    it { should validate_presence_of :max_participants_per_table }
    it { should validate_numericality_of :max_participants_per_table }
    it { should validate_presence_of :tenant }
  end

  it_should_behave_like 'a_scoped_object', :project

  context "with tenant scope" do
    describe "defaults" do 
      subject { Project.new }
      its(:start_time) { should be_within(1).of(Time.now) }
    end

    describe "setting start date and start time_" do
      it_should_behave_like "schedulable", :start_date, :start_time do
        def create_schedulable(attrs = {}) 
          Project.new(attrs)
        end
      end
    end

  end

end
