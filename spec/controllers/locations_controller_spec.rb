require 'spec_helper'

describe LocationsController do
  render_views
  prepare_scope :tenant

  let(:location) { FactoryGirl.create :location, :published => true }
  alias_method :create_location, :location

  describe "GET index" do
    it "assigns all published locations locations" do
      create_location
      get :index, {}
      assigns(:locations).should eq([location])
    end

    context "when no locations availables" do
      it "it renders no locations" do
        get :index
        assigns(:locations).should eq([])
      end
      it "renders a new organisiers link" do
        get :index 
        response.body.should have_selector("a[href='#{new_registration_organizer_url}']")
      end
    end
  end

  describe "GET show" do
    it "assigns the requested location as @location" do
      FactoryGirl.create :conversation, :location => location
      get :show, {:id => location.id}
      assigns(:location).should eq(location)
    end
    it "says not found if location is not published" do
      location.update_attribute :published, false
      get :show, {:id => location.id}
      should respond_with(404)
    end
  end

end
