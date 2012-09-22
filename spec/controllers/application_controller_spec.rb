require 'spec_helper' 


describe 'application_controller' do
  class MyController < ApplicationController
    def index
      render :text => ''
    end
    def index_for_tenant
      current_tenant
      render :text => ''
    end
  end

  describe MyController do

    describe 'requesting a url' do
      context "when host is not found as a tenant" do
        it "current tenant is nil by default" do
          get :index
          Tenant.current.should == nil
        end
        it "responds with a not found if tenant is needed" do
          expect { get :index_for_tenant }.to raise_error(ActionController::RoutingError)
        end
      end
      context "when host is found as a tenant" do
        it "is found if host is found as host" do
          current = FactoryGirl.create :tenant, :host => 'test.host'
          get :index
          Tenant.current.should == current
        end
      end
    end
  end

  describe City::LocationsController do

    context "with tenant scope" do
      prepare_scope :tenant

      describe 'not allowed for action' do
        login_as :organizer
        before do
          ActionGuard.stub(:authorized?).and_return false
          get :index
        end
        it "redirects to login with a message" do
          response.should be_redirect
          response.should redirect_to login_path
          flash[:alert].should == I18n.t('not_authorized')
        end
        it "signs out" do
          controller.should_not be_signed_in
        end
      end
      describe "not logged in yet for action" do
        before do
          ActionGuard.stub(:authorized?).and_return false
          get :index
        end
        it "redirects to login with the url passed to 'for'" do
          response.should be_redirect
          response.should redirect_to login_path(for: city_locations_path)
        end
        it "should notice that it sends along" do
          flash[:notice].should == I18n.t('send_along')
        end
      end
    end
  end
end
