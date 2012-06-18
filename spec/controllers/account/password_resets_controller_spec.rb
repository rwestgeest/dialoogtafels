require 'spec_helper'

describe Account::PasswordResetsController do
  render_views
  prepare_scope :tenant
  let(:account) { FactoryGirl.create :coordinator_account  }
  def valid_attributes 
    { email: account.email }
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
      response.body.should have_selector("form[action='#{account_password_reset_path(assigns(:account))}']") do |form|
        form.should_have_selector('input#account_email')
      end
    end
  end

  describe "POST 'create'" do
    context "with valid parameters" do
      it "redirects to success" do
        post 'create', :account => valid_attributes
        response.should redirect_to(success_account_password_reset_path)
      end
      it "resets the password" do
        TenantAccount.any_instance.should_receive :reset!
        post 'create', :account => valid_attributes
      end
    end
    shared_examples_for "an_unfound_email_for_password_reset_query" do
      it "renders the form again" do
        response.should be_success
        response.should render_template(:new)
      end
      it "sets the flash alert" do
        response.body.should have_selector "#alert"
      end
    end
    context "with invalid parameters" do
      before {  post 'create', :account => { email: 'wrong' } } 
      it_should_behave_like "an_unfound_email_for_password_reset_query" 
    end
    context "for another tenant" do
      before do
        for_tenant(FactoryGirl.create :tenant) do
          @other_account = FactoryGirl.create :confirmed_account
        end
        post 'create', :account => { email: @other_account.email, password: @other_account.password }
      end
      it_should_behave_like "an_unfound_email_for_password_reset_query" 
    end
    context "for a maintainer account" do
      before do
        @other_account = FactoryGirl.create :confirmed_maintainer_account
        post 'create', :account => { email: @other_account.email, password: @other_account.password }
      end
      it_should_behave_like "an_unfound_email_for_password_reset_query" 
    end
  end

end
