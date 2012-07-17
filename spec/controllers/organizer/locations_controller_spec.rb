require 'spec_helper'

describe Organizer::LocationsController do
  render_views
  prepare_scope :tenant
  login_as :organizer

  def valid_attributes
    FactoryGirl.attributes_for :location
  end

  def current_organizer
    current_account.highest_contribution
  end

  def create_location(attributes = {})
    FactoryGirl.create :location, { :organizer => current_organizer }.merge(attributes)
  end

  def index_url(*args)
    organizer_locations_url(*args)
  end

  describe "GET index" do
    let!(:location) { create_location }
    let!(:other_location) { create_location(:organizer => FactoryGirl.create(:organizer)) }

    before { get :index, {} }

    it "assigns all organizer_locations as @organizer_locations" do
      assigns(:locations).should eq([location])
    end
    it "renders the index page" do
      response.should be_success
      response.should render_template 'index'
    end
  end

  describe "GET new" do
    it "assigns a new location as @location" do
      get :new, {}
      assigns(:location).should be_a_new(Location)
    end
  end


  it_should_behave_like "a_locations_creator"

end
