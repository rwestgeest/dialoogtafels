require 'spec_helper'

describe Account  do
  describe 'validations' do
    it { should validate_presence_of :email }
    describe "on password" do 
      let!(:account) { FactoryGirl.create :maintainer_account, :password => nil, :password_confirmation => nil }
      it "accepts no password on create" do
        account.should be_persisted
      end
      it "requires password on save" do
        account.save.should be_false
        account.errors_on(:password).should_not be_empty
      end
    end
  end

  describe 'change password' do
    attr_reader :account
    let(:old_password) { account.password }

    before do 
      @account = FactoryGirl.create(:coordinator_account, :password => "secret", :password_confirmation => "secret")
      @account.confirm!
      @account = Account.find(@account.id)
    end

    it "updates password if password is passed and matches password_confirmation" do
      account.update_attributes(:password => 'secret', :password_confirmation => 'secret').should be_true
      account.password.should == 'secret'
    end

    it "ignores passwords if not passed " do
      new_mail = FactoryGirl.generate(:email)
      account.password.should == old_password
    end

    it "ingores passwords if nil" do
      account.update_attributes({:password => nil}).should be_true
      account.password.should == old_password
    end
  end

  shared_examples_for "a confirmable account" do
    it "is initially not confirmed" do
      account.should_not be_confirmed
    end

    context "without_password" do
      it "fails" do
        account.confirm!.should be_false
        account.reload #reload the account from database by id
        account.should_not be_confirmed
      end
    end

    describe "with_password" do

      describe "with valid password" do 
        attr_reader :confirmation_result

        before do 
          @confirmation_result = account.confirm_with_password :password => 'secret', :password_confirmation => 'secret'
          account.reload
        end

        it "returns true and confirms" do
          confirmation_result.should be_true
          account.should be_confirmed
        end

        it "sets password" do
          account.encrypted_password.should_not be_empty
        end
      end

      describe "with invalid password" do 
        it "returns false and does not confirm" do
          account.confirm_with_password(:password => '').should be_false
          account.should_not be_confirmed
        end
      end
    end
  end

  describe 'confirm' do 
    context "maintainer" do
      let(:account) { 
        FactoryGirl.create(:maintainer_account, 
                        :password => nil, 
                        :password_confirmation => nil)
      }

      it_should_behave_like "a confirmable account"
    end
    context "organizer" do
      let(:account) { 
        FactoryGirl.create(:organizer_account, 
                        :password => nil, 
                        :password_confirmation => nil)
      }

      it_should_behave_like "a confirmable account"
    end
    context "coordinator" do
      let(:account) { 
        FactoryGirl.create(:coordinator_account, 
                        :password => nil, 
                        :password_confirmation => nil)
      }

      it_should_behave_like "a confirmable account"
    end
  end

  describe "creation methods" do
    it "maintainer creates maintainer" do
      Account.maintainer.role == Account::Maintainer
    end
    it "organizer creates organizer" do
      Account.organizer.role == Account::Organizer
    end
  end

end
