require 'spec_helper' 


describe 'application_controller' do
  class MyController < ApplicationController
    def index
      render :text => ''
    end
  end
  describe MyController do
    describe 'current tenant' do
      it "is nil by default" do
        get :index
        Tenant.current.should == nil
      end
      it "is found if subdomain is found as url code" do
        current = FactoryGirl.create :tenant, :url_code => 'test'
        get :index
        Tenant.current.should == current
      end
    end
    context "with tenant scope" do
      prepare_scope :tenant
      describe 'not allowed for action' do
        login_as :organizer
        before do
          ActionGuard.stub(:authorized?).and_return false
          get :index
        end
        it "redirects to root" do
          response.should be_redirect
          response.should redirect_to '/'
        end
        it "signs out" do
          controller.should_not be_signed_in
        end
      end
    end
  end
end
