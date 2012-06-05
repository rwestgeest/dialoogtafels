require 'spec_helper'

describe Account::PasswordResetsController do
  render_views
  prepare_scope :tenant
  let(:account) { FactoryGirl.create :maintainer_account  }
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
        MaintainerAccount.any_instance.should_receive :reset!
        post 'create', :account => valid_attributes
      end
    end
    context "with invalid parameters" do
      before {  post 'create', :account => { email: 'wrong' } } 
      it "renders the form again" do
        response.should be_success
        response.should render_template(:new)
      end
      it "sets the flash alert" do
        response.body.should have_selector "#alert"
      end
    end
  end

end
