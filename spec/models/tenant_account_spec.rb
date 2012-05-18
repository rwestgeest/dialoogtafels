require 'spec_helper'

describe TenantAccount do
  it_should_behave_like "a_scoped_object", :tenant_account

  describe "creation methods" do
    it "contributor creates contributor" do
      TenantAccount.contributor.role == Account::Contributor
    end
  end
  context "within tenant scope" do
    prepare_scope :tenant

    describe "coordinator validations" do
      let!(:account) { FactoryGirl.create :coordinator_account, :password => nil, :password_confirmation => nil }
      it_should_behave_like "an_account_validator"
      it { should validate_presence_of(:person) }
      it { should belong_to :person } 
    end

    describe 'creation' do
      it "creates an account" do
        expect { FactoryGirl.create :coordinator_account }.to change(TenantAccount, :count).by(1)
      end
      it "sends a welcome message" do
        Postman.should_receive(:deliver).with(:account_welcome, an_instance_of(TenantAccount))
        account = FactoryGirl.create :coordinator_account
      end
    end
  end
end

