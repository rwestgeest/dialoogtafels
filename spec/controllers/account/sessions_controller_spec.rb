require 'spec_helper'

describe Account::SessionsController do
  render_views
  prepare_scope :tenant

  let(:account) { FactoryGirl.create :confirmed_account  }
  alias_method :create_account, :account
  let(:maintainer_account) { FactoryGirl.create :confirmed_maintainer_account }
  alias_method :create_maintainer_account, :maintainer_account

  def valid_attributes 
    { email: account.email, password: account.password }
  end

  describe "GET 'new'" do

    it "returns http success" do
      get 'new'
      response.should be_success
      response.body.should have_selector("form[action='#{account_session_path(assigns(:account))}']") 
      response.body.should have_selector('form input#account_email')
      response.body.should have_selector('form input#account_password')
    end

    it "should not have a maintainer input" do
      get "new"
      response.body.should_not have_selector('form input#maintainer')
    end

    context "when email passed" do
      it "fills in the email address" do
        get "new", :email => "some@email.com" 
        response.body.should have_selector("form input#account_email[value='some@email.com']")
      end
    end

    context "with maintainer type" do
      before { get "new", :maintainer => "maintainer" }
      it "renders the form" do
        response.should be_success
        response.body.should have_selector("form[action='#{account_session_path(assigns(:account))}']") 
        response.body.should have_selector('form input#account_email')
        response.body.should have_selector('form input#account_password')
      end

      it "should have a maintainer input" do
        response.body.should have_selector('form input#maintainer')
      end
    end
  end

  describe "POST 'create'" do
    def login(account_credentials, password_override = nil)
      post 'create', 
        :account => {
          :email => account_credentials.email, 
          :password => password_override && password_override || account_credentials.password
        }
    end
    def maintainer_login(account_credentials, password_override = nil)
      post 'create', 
        :maintainer => "maintainer",
        :account => { 
          :email => account_credentials.email, 
          :password => password_override && password_override || account_credentials.password
        }
    end

    context "with valid parameters" do
      it "redirect to the accounts landing page" do
        login(account)
        response.should redirect_to(account.landing_page)
      end

      it "logs in" do
        login(account)
        current_account.should == account
        @controller.send(:current_account).should == account
      end
    end

    shared_examples_for "a_failed_login" do
      it "renders the form again" do
        response.should be_success
        response.should render_template(:new)
      end
      it "sets the flash alert" do
        response.body.should have_selector "#alert"
      end
    end
    context "with invalid parameters" do
      before { login(account, 'boguspass') }

      it_should_behave_like "a_failed_login"

      it "does not render the hidden maintainer field" do
        response.body.should_not have_selector('form input#maintainer')
      end
    end

    context "for another tenant" do
      before do
        for_tenant(FactoryGirl.create :tenant) do
          @other_account = FactoryGirl.create :confirmed_account
        end
        login @other_account
      end
      it_should_behave_like "a_failed_login"
    end

    context "for a maintainer account" do
      before { login maintainer_account }
      it_should_behave_like "a_failed_login"
    end

    context "when maintainer is set" do
      before { maintainer_login maintainer_account }
      it "logs in" do
        current_account.should == maintainer_account
      end 
      it "should redirect to the accounts landing page" do
        response.should redirect_to current_account.landing_page
      end
      context "with wrong password" do
        before { maintainer_login maintainer_account, 'boguspass' }

        it_should_behave_like "a_failed_login"

        it "renders the hidden maintainer field" do
          response.body.should have_selector('form input#maintainer')
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    login_as :organizer
    it "signs out the current account" do
      delete 'destroy'
      current_account.should == nil
    end
    it "redirects to sessions/new " do
      delete 'destroy'
      response.should redirect_to(root_path)
    end
  end
end
