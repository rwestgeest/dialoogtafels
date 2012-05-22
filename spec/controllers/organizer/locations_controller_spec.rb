require 'spec_helper'

describe Organizer::LocationsController do
  render_views
  prepare_scope :tenant
  login_as :organizer

  def valid_attributes
    FactoryGirl.attributes_for :location
  end

  def current_organizer
    current_account.active_contribution
  end

  def create_location(attributes = {})
    FactoryGirl.create :location, { :organizer => current_organizer }.merge(attributes)
  end

  describe "GET index" do
    it "assigns all organizer_locations as @organizer_locations" do
      location = create_location
      other_location = create_location(:organizer => FactoryGirl.create(:organizer))
      get :index, {}
      assigns(:locations).should eq([location])
    end
  end

  describe "GET show" do
    it "assigns the requested location as @location" do
      location = create_location
      get :show, {:id => location.id}
      assigns(:location).should eq(location)
    end
  end

  describe "GET new" do
    it "assigns a new location as @location" do
      get :new, {}
      assigns(:location).should be_a_new(Location)
    end
  end

  shared_examples_for "an_edit_renderer" do

    it "renders the edit template" do
      do_action
      response.should render_template 'edit'
    end
    it "renders 'step_conversations' when step is conversation rounds" do
      do_action :step => 'conversations'
      response.should render_template 'step_conversations'
    end
    it "renders 'step_conversations' when step is publication" do
      do_action :step => 'publication'
      response.should render_template 'step_publication'
      response.body.should have_selector "input[name='step'][value='publication'][type='hidden']"
    end

    it "renders 'edit' on an illegal step" do
      do_action :step => 'bogus' 
      response.should render_template 'edit'
    end
  end

  describe "GET edit" do
    let(:location) { create_location }
    def do_action(extra_params = {})
      get :edit, {:id => location.to_param}.merge(extra_params)
    end
    it "assigns the requested location as @location" do
      do_action
      assigns(:location).should eq(location)
    end
    it_should_behave_like "an_edit_renderer"
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Location" do
        expect {
          post :create, {:location => valid_attributes}
        }.to change(Location, :count).by(1)
      end

      it "assigns a newly created location as @location" do
        post :create, {:location => valid_attributes}
        assigns(:location).should be_a(Location)
        assigns(:location).should be_persisted
      end

      it "redirects to the created location" do
        post :create, {:location => valid_attributes}
        response.should redirect_to(organizer_location_url(Location.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved location as @location" do
        # Trigger the behavior that occurs when invalid params are submitted
        Location.any_instance.stub(:save).and_return(false)
        post :create, {:location => {}}
        assigns(:location).should be_a_new(Location)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Location.any_instance.stub(:save).and_return(false)
        post :create, {:location => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    let!(:location) { create_location }

    def do_action(extra_params = {}) 
      put :update, {:id => location.to_param, :location => valid_attributes}.merge(extra_params)
    end

    describe "with valid params" do
      it "updates the requested location" do
        # Assuming there are no other organizer_locations in the database, this
        # specifies that the Location created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Location.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => location.to_param, :location => {'these' => 'params'}}
      end

      it "assigns the requested location as @location" do
        do_action
        assigns(:location).should eq(location)
      end

      it "redirects to the location" do
        do_action
        response.should redirect_to(organizer_location_url(location))
      end
    end

    describe "with invalid params" do
      # Trigger the behavior that occurs when invalid params are submitted
      before {  Location.any_instance.stub(:save).and_return(false) }
      it "assigns the location as @location" do
        do_action
        assigns(:location).should eq(location)
      end

      it_should_behave_like "an_edit_renderer"
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested location" do
      location = create_location
      expect {
        delete :destroy, {:id => location.to_param}
      }.to change(Location, :count).by(-1)
    end

    it "redirects to the organizer_locations list" do
      location = create_location
      delete :destroy, {:id => location.to_param}
      response.should redirect_to(organizer_locations_url)
    end
  end

end
