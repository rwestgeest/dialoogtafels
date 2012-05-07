require 'spec_helper'

describe Project do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :tenant }
  end

  describe 'associations' do
    it { should belong_to :tenant }
  end

  describe 'multitenancy' do
    let(:tenant_a) { FactoryGirl.create :tenant } 
    let(:tenant_b) { FactoryGirl.create :tenant } 

    describe 'finding' do
      let!(:project_a) { FactoryGirl.create :project, :tenant => tenant_a }
      let!(:project_b) { FactoryGirl.create :project, :tenant => tenant_b }
      it 'should find in scope of current tenant' do
        Tenant.current = tenant_a
        Project.all.should == [project_a]
        Tenant.current = tenant_b
        Project.all.should == [project_b]
      end
      it 'should find no projects if tenant = nil' do
        Tenant.current = nil
        Project.all.should be_empty 
      end
    end
    describe 'creating' do
      it 'should create a project for the current tenant' do
        Tenant.current = tenant_a
        Project.create FactoryGirl.attributes_for(:project)
        Project.last.tenant.should == tenant_a

        Tenant.current = tenant_b
        Project.create FactoryGirl.attributes_for(:project)
        Project.last.tenant.should == tenant_b
      end
      it 'should create a project other tenant if requested' do
        Tenant.current = tenant_a
        p = Project.create! FactoryGirl.attributes_for(:project).merge(:tenant_id => tenant_b.id)
        p.should be_persisted 
        p.tenant.should == tenant_b
      end
      it "fails on creation when current tenant is not set" do
        Tenant.current = nil
        expect { 
          Project.create! FactoryGirl.attributes_for(:project)
        }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

  end
end
