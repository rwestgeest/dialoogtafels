require 'spec_helper'

describe Account::PasswordsController do
  render_views
  prepare_scope :tenant
  login_as :contributor

  def valid_parameters
    {:password => 'secret', :password_confirmation => 'secret' }
  end
  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
      response.body.should have_selector("form[action='#{account_password_path}']") do |form|
        form.should have_selector['input@account_password']
        form.should have_selector['input@account_password_confirmation']
      end
    end
  end
  describe "PUT 'update'" do
    context "with valid params" do
      before { put 'update', :account => valid_parameters }
      it "redirects to the accounts langding page" do
        response.should redirect_to(current_account.landing_page)
      end
      it "updates the password" do
        current_account.authenticate('secret').should be_true
      end
      it "confirms the account" do
        current_account.should be_confirmed
      end
    end
    context "with invalid params" do
      before {
        put 'update', :account => valid_parameters.merge(:password_confirmation => 'terces')
      }
      it "renders the edit form again" do
        response.should render_template :edit
      end
    end
  end

end
