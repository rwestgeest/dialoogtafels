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
  end
end
