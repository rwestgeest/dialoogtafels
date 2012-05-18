require "spec_helper"

describe Organizer::LocationsController do
  describe "routing" do

    it "routes to #index" do
      get("/organizer/locations").should route_to("organizer/locations#index")
    end

    it "routes to #new" do
      get("/organizer/locations/new").should route_to("organizer/locations#new")
    end

    it "routes to #show" do
      get("/organizer/locations/1").should route_to("organizer/locations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/organizer/locations/1/edit").should route_to("organizer/locations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/organizer/locations").should route_to("organizer/locations#create")
    end

    it "routes to #update" do
      put("/organizer/locations/1").should route_to("organizer/locations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/organizer/locations/1").should route_to("organizer/locations#destroy", :id => "1")
    end

  end
end
