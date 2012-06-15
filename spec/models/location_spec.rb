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
    it { should have_many :conversations }

  end

  it_should_behave_like 'a_scoped_object', :location

  context "with current tenant" do
    prepare_scope :tenant

    describe "a new location" do
      it "should have the tenants name as city by default " do  
        Location.new.city.should == Tenant.current.name 
      end
      it "'s city can be overridden" do  
        Location.new(:city => "rotterdam").city.should == "rotterdam"
      end
    end
    describe "creating an location" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :location 
        Location.last.project.should == Tenant.current.active_project
      end
    end

    describe "publisheds" do
      let!(:published) { FactoryGirl.create :location, :published => true }
      let!(:concept) { FactoryGirl.create :location, :published => false }
      subject { Location.publisheds }
      it { should include published }
      it { should_not include concept }
    end
  end

end
