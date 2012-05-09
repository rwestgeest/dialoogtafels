require 'spec_helper'

describe Account  do
  it_should_behave_like "a_scoped_object", :account, :tenant

  describe "creation methods" do
    it "maintainer creates maintainer" do
      Account.maintainer.role == Account::Maintainer
    end
    it "organizer creates organizer" do
      Account.organizer.role == Account::Organizer
    end
  end

  context "within tenant scope" do
    prepare_scope :tenant
    describe 'validations' do
      let!(:account) { FactoryGirl.create :maintainer_account, :password => nil, :password_confirmation => nil }
      it { should validate_presence_of :email }
      it { should validate_uniqueness_of :email }
      it { should allow_value("some@mail.nl").for(:email) }
      ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
        it { should_not allow_value(illegal_mail).for(:email) }
      end
      it { should validate_presence_of :role } 

      describe "on password" do 
        it "accepts no password on create" do
          account.should be_persisted
        end
        it "requires password on save" do
          account.save.should be_false
          account.errors_on(:password).should_not be_empty
        end
      end
    end

    describe 'generate_perishable_token' do
      let!(:existing_account) { FactoryGirl.create :maintainer_account }
      let(:account) { Account.new }
      it "generates some random token" do
        TokenGenerator.stub(:generate_token => "first_generated_token")
        account.generate_perishable_token
        account.perishable_token.should == "first_generated_token"
      end
      it "makes sure it is unique" do
        TokenGenerator.stub(:generate_token).and_return(existing_account.perishable_token, existing_account.perishable_token, "first_free_generated_token")
        account.generate_perishable_token
        account.perishable_token.should == "first_free_generated_token"
      end
    end

    describe 'authenticate' do
      let!(:account) { FactoryGirl.create :maintainer_account } 
      describe 'on token' do
        it "fails when token is nil" do
          account.update_attribute :perishable_token, nil
          Account.authenticate_by_token(nil).should be_nil 
        end
        it "fails when token is empty" do
          account.update_attribute :perishable_token, ''
          Account.authenticate_by_token('').should be_nil 
        end
        it "passes when token is present" do
          Account.authenticate_by_token(account.perishable_token).should == account
        end
      end
      describe 'on password' do
        before { account.confirm_with_password :password => 'secret', :password_confirmation => 'secret' }
        it "fails when password does not match" do
          Account.authenticate_by_email_and_password(account.email, 'xxxx').should be_nil
          Account.authenticate_by_email_and_password("other"+account.email, 'secret').should be_nil
        end
        it "passes when password matcher" do
          Account.authenticate_by_email_and_password(account.email, 'secret').should == account
        end
        it "fails when account is not confirmed" do
          account.update_attribute :confirmed_at, nil
          Account.authenticate_by_email_and_password(account.email, 'secret').should be_nil
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

      it "should have a confirmation token" do
        account.perishable_token.should_not be_empty
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

  end
end
