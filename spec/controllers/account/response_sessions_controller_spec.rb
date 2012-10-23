require 'spec_helper'

describe Account::ResponseSessionsController do
  render_views
  prepare_scope :tenant

  let(:account) { FactoryGirl.create :coordinator_account  }

  describe "GET 'show'" do
    context 'with valid token' do
      it "returns http success" do
        get 'show', :id => account.authentication_token
        response.should redirect_to account.landing_page
      end
      it "logs in" do
        get 'show', :id => account.authentication_token
        current_account.should == account
        @controller.send(:current_account).should == account
      end
    end
    context "with invalid parameters" do
      it "renders the form again" do
        get 'show', :id => "wrong_token"
        should respond_with(404)
      end
    end
  end

end
