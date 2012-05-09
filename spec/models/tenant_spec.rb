require 'spec_helper'
describe Tenant, :focus => true do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :url_code }
    it { should validate_presence_of :site_url }
    it { should validate_presence_of :representative_email }
    it { should validate_presence_of :representative_telephone }
    it { should validate_presence_of :representative_name }
    it { should validate_presence_of :invoice_address }
  end

  describe 'creating a tenant with account' do
    it "creates the tenant" do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant) }.to change { Tenant.count }.by(1)
    end
    it "creates an admin account" do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant) }.to change { Account.unscoped.count }.by(1)
    end
    it "creates an person for the account" do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant) }.to change { Person.unscoped.count }.by(1)
    end
    it "creates an noting when either not valid" do
      expect { Tenant.create(FactoryGirl.attributes_for(:tenant, :name => nil)) }.not_to change { Account.unscoped.count }.by(1)
    end
    it "creates a first and active project"  do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant) }.to change { Project.unscoped.count }.by(1)
      Project.unscoped.last.tenant.should == Tenant.last
      Tenant.current = Tenant.last
      Tenant.last.active_project.should == Project.unscoped.last
    end
    after { Tenant.current = nil }
  end
end
