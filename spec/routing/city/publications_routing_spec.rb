require "spec_helper"

describe City::PublicationsController do
  describe "routing" do

    it "routes to #new" do
      get("/city/locations/1/publication/new").should route_to("city/publications#new", :location_id => "1")
    end

    it "routes to #show" do
      get("/city/locations/1/publication").should route_to("city/publications#show", :location_id => "1")
    end

    it "routes to #edit" do
      get("/city/locations/1/publication/edit").should route_to("city/publications#edit", :location_id => "1")
    end

    it "routes to #create" do
      post("/city/locations/1/publication").should route_to("city/publications#create", :location_id => "1")
    end

    it "routes to #update" do
      put("/city/locations/1/publication").should route_to("city/publications#update", :location_id => "1")
    end

  end
end
