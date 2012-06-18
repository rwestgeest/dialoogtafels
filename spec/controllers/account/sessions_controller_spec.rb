require 'spec_helper'

describe Account::SessionsController do
  render_views
  prepare_scope :tenant
  let(:account) { FactoryGirl.create :confirmed_account  }
  def valid_attributes 
    { email: account.email, password: account.password }
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
      response.body.should have_selector("form[action='#{account_session_path(assigns(:account))}']") do |form|
        form.should_have_selector('input#account_email')
        form.should_have_selector('input#account_password')
      end
    end
  end

  describe "POST 'create'" do
    context "with valid parameters" do
      it "redirect to the accounts landing page" do
        post 'create', :account => valid_attributes
        response.should redirect_to(account.landing_page)
      end
      it "logs in" do
        post 'create', :account => valid_attributes
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
      before {   post 'create', :account => valid_attributes.merge(password: 'false') }
      it_should_behave_like "a_failed_login"
    end
    context "for another tenant" do
      before do
        for_tenant(FactoryGirl.create :tenant) do
          @other_account = FactoryGirl.create :confirmed_account
        end
        post 'create', :account => { email: @other_account.email, password: @other_account.password }
      end
      it_should_behave_like "a_failed_login"
    end
    context "for a maintainer account" do
      before do
        @other_account = FactoryGirl.create :confirmed_maintainer_account
        post 'create', :account => { email: @other_account.email, password: @other_account.password }
      end
      it_should_behave_like "a_failed_login"
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
      response.should redirect_to(new_account_session_path)
    end
  end
end
