require "spec_helper"

describe City::LocationsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/locations").should route_to("city/locations#index")
    end

    it "routes to #new" do
      get("/city/locations/new").should route_to("city/locations#new")
    end

    it "routes to #show" do
      get("/city/locations/1").should route_to("city/locations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/city/locations/1/edit").should route_to("city/locations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/city/locations").should route_to("city/locations#create")
    end

    it "routes to #update" do
      put("/city/locations/1").should route_to("city/locations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/city/locations/1").should route_to("city/locations#destroy", :id => "1")
    end

  end
end
