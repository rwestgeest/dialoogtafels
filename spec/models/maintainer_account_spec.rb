require 'spec_helper'

describe MaintainerAccount do

  describe "creation methods" do
    it "maintainer creates maintainer" do
      MaintainerAccount.maintainer.role == MaintainerAccount::Maintainer
    end
  end

  describe "validations" do
    let!(:account) { 
      FactoryGirl.create :maintainer_account, :password => nil, :password_confirmation => nil 
    }
    it_should_behave_like "an_account_validator"
    it { should_not validate_presence_of(:person) }
  end

  context 'creation' do
    it "creates an account" do
      expect { FactoryGirl.create :maintainer_account }.to change(MaintainerAccount, :count).by(1)
    end
  end

end

