require 'spec_helper'

describe Location do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_organizer) { FactoryGirl.create :locations } 
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :postal_code }
    it { should validate_presence_of :city }
    it { should validate_presence_of :organizer }

  end

  it_should_behave_like 'a_scoped_object', :location

  context "with current tenant" do
    prepare_scope :tenant

    describe "creating an location" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :location 
        Location.last.project.should == Tenant.current.active_project
      end
    end
  end

end