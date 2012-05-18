require 'spec_helper'

describe Organizer do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_organizer) { FactoryGirl.create :organizer } 
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :person }
    it { should_not allow_value(existing_organizer.email).for(:email) }
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
  end

  it_should_behave_like 'a_scoped_object', :organizer

  context "with current tenant" do
    prepare_scope :tenant

    describe "creating an organizer" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :organizer 
        Organizer.last.project.should == Tenant.current.active_project
      end

      it "creates an person" do
        expect{ FactoryGirl.create :organizer }.to change(Person, :count).by(1)
        Organizer.last.person.should == Person.last
      end

      it "creates a worker account with role organizer" do
        expect{ FactoryGirl.create :organizer }.to change(Account, :count).by(1)
        Account.last.person.should == Person.last
      end

      it "sends a welcome message" do
        Postman.should_receive(:deliver).with(:account_welcome, an_instance_of(Account))
        FactoryGirl.create :organizer 
      end
    end
  end
end
