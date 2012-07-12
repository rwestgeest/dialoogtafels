require 'spec_helper'

class MyPublicController < PublicController
  def show
    render text: '', layout: true
  end
end

describe MyPublicController do
  prepare_scope :tenant
  describe "layout" do

    it "is public by default" do
      get :show 
      response.should render_template 'layouts/public'
    end

    it "is framed when tentant has framed_integration" do
      Tenant.current.update_attribute :framed_integration, true
      get :show
      response.should render_template 'layouts/framed'
    end

  end
end
