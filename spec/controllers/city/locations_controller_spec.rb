require 'spec_helper'


describe City::LocationsController do
  render_views 
  prepare_scope :tenant
  login_as :coordinator

  before(:all) { @organizer = FactoryGirl.create :organizer } 

  attr_reader :organizer

  def valid_attributes
    FactoryGirl.attributes_for(:location).merge :organizer_id => organizer.id
  end

  def create_location(attributes = {})
    FactoryGirl.create :location, attributes
  end

  def index_url(*args)
    city_locations_url(*args)
  end

  describe "GET index" do
    let!(:location) { create_location }
    it "assigns all locations as @locations" do
      get :index, {}
      assigns(:locations).should eq([location])
    end

    context "with todo item supplied" do
      let(:todo) {FactoryGirl.create :location_todo, :project => location.project }
      def do_get 
        get :index, :todo => todo.id 
      end
      it "assigns the selected todo" do
        do_get
        assigns(:selected_todo).should == todo
      end
      it "filters the locations on the ones with that todo unfinished" do
        location_with_finished_todo = create_location(project: location.project)
        location_with_finished_todo.tick_done(todo.id)
        do_get
        assigns(:locations).should == [location]
      end
    end
  end

  describe "GET show" do
    it "assigns the requested location as @location" do
      location = create_location
      get :show, {:id => location.to_param}
      assigns(:location).should eq(location)
    end
  end

  describe "GET new" do
    context "without an organizer" do
      it "renders an organizer selection" do
        get :new, {}
        assigns(:organizers).should == [organizer]
        response.should render_template :select_organizer
        response.body.should have_selector("form[action='#{new_city_location_path}'][method='get']")
      end
    end
    it "assigns a new location as @location" do
      get :new, {:organizer_id => organizer.to_param}
      assigns(:location).should be_a_new(Location)
    end
    it "assigns the organizer_id to the location" do
      get :new, :organizer_id => organizer.to_param
      assigns(:location).organizer.should == organizer
      response.body.should have_selector("input[name='location[organizer_id]'][value='#{ organizer.to_param }']")
    end
  end

  it_should_behave_like "a_locations_editor"
  it_should_behave_like "a_locations_creator"
end
