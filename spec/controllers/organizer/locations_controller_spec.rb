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

  describe "GET edit" do
    it "assigns the requested location as @location" do
      location = create_location
      get :edit, {:id => location.to_param}
      assigns(:location).should eq(location)
    end
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
    describe "with valid params" do
      it "updates the requested location" do
        location = create_location
        # Assuming there are no other organizer_locations in the database, this
        # specifies that the Location created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Location.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => location.to_param, :location => {'these' => 'params'}}
      end

      it "assigns the requested location as @location" do
        location = create_location
        put :update, {:id => location.to_param, :location => valid_attributes}
        assigns(:location).should eq(location)
      end

      it "redirects to the location" do
        location = create_location
        put :update, {:id => location.to_param, :location => valid_attributes}
        response.should redirect_to(organizer_location_url(location))
      end
    end

    describe "with invalid params" do
      it "assigns the location as @location" do
        location = create_location
        # Trigger the behavior that occurs when invalid params are submitted
        Location.any_instance.stub(:save).and_return(false)
        put :update, {:id => location.to_param, :location => {}}
        assigns(:location).should eq(location)
      end

      it "re-renders the 'edit' template" do
        location = create_location
        # Trigger the behavior that occurs when invalid params are submitted
        Location.any_instance.stub(:save).and_return(false)
        put :update, {:id => location.to_param, :location => {}}
        response.should render_template("edit")
      end
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