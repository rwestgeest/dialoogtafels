require "spec_helper"

describe Organizer::LocationsController do
  describe "routing" do

    it "routes to #index" do
      get("/organizer/locations").should route_to("organizer/locations#index")
    end

    it "routes to #new" do
      get("/organizer/locations/new").should route_to("organizer/locations#new")
    end

    it "routes to #create" do
      post("/organizer/locations").should route_to("organizer/locations#create")
    end

  end
end
