require 'spec_helper'

describe LocationsController do
  render_views
  prepare_scope :tenant

  let(:location) { FactoryGirl.create :location }
  alias_method :create_location, :location

  describe "GET index" do
    it "assigns all locations locations" do
      create_location
      get :index, {}
      assigns(:locations).should eq([location])
    end
  end

  describe "GET show" do
    it "assigns the requested location as @location" do
      FactoryGirl.create :conversation, :location => location
      get :show, {:id => location.id}
      assigns(:location).should eq(location)
    end
  end

end
