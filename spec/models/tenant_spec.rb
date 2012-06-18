require 'spec_helper'
describe Tenant do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :url_code }
    it { should validate_presence_of :site_url }
    it { should validate_presence_of :representative_email }
    it { should validate_presence_of :representative_telephone }
    it { should validate_presence_of :representative_name }
    it { should validate_presence_of :invoice_address }
  end

  shared_examples_for 'a_tenant_creator' do
    it "creates the tenant" do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant, name: "new_tenant 1") }.to change { Tenant.count }.by(1)
    end
    it "creates an admin account" do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant, name: "new_tenant 2") }.to change { Account.unscoped.count }.by(1)
      for_tenant(Tenant.last) do
        Account.last.tenant.should == Tenant.last
      end
    end
    it "creates an person for the account" do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant, name: "new_tenant 3") }.to change { Person.unscoped.count }.by(1)
      for_tenant(Tenant.last) do
        Account.last.person.should == Person.last
        Person.last.tenant.should == Tenant.last
      end
    end
    it "can create more tenants with same representative email" do
      expect { 
        Tenant.create(FactoryGirl.attributes_for :tenant, :representative_email => "repre@sentative.nl")
        Tenant.create(FactoryGirl.attributes_for :tenant, :representative_email => "repre@sentative.nl")
      }.to change { Tenant.count }.by(2)
    end
    it "creates an account for each tenant with same representative email" do
      expect { 
        Tenant.create(FactoryGirl.attributes_for :tenant, :representative_email => "repre@sentative.nl")
        Tenant.create(FactoryGirl.attributes_for :tenant, :representative_email => "repre@sentative.nl")
      }.to change { Account.unscoped.count }.by(2)
    end
    it "creates a person for each tenant with same representative email" do
      expect { 
        Tenant.create(FactoryGirl.attributes_for :tenant, :representative_email => "repre@sentative.nl")
        Tenant.create(FactoryGirl.attributes_for :tenant, :representative_email => "repre@sentative.nl")
      }.to change { Person.unscoped.count }.by(2)
    end
    it "creates noting when either not valid" do
      expect { Tenant.create(FactoryGirl.attributes_for(:tenant, :name => nil)) }.not_to change { Account.unscoped.count }.by(1)
    end
    it "creates a first and active project"  do
      expect { Tenant.create(FactoryGirl.attributes_for :tenant, name: "new_tenant 4") }.to change { Project.unscoped.count }.by(1)
      Project.unscoped {
        Project.last.tenant.should == Tenant.last
        Tenant.last.active_project_id.should == Project.last.id
        Project.last.name.should include Date.today.year.to_s
      }
    end
    it "the current tenant is left unchanged" do
      for_tenant (nil) do # suppose it is nil
        expect { Tenant.create(FactoryGirl.attributes_for :tenant) }.not_to change(Tenant, :current)
      end
    end
  end
  describe 'creating a tenant with account' do
    it_should_behave_like 'a_tenant_creator'
    context "with a different current tenant" do
      prepare_scope :tenant
      it_should_behave_like 'a_tenant_creator'
    end
  end
end
