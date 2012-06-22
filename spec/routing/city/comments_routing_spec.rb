require "spec_helper"

describe City::CommentsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/locations/1/comments").should route_to("city/comments#index", :location_id => "1")
    end

    it "routes to #create" do
      post("/city/locations/1/comments").should route_to("city/comments#create", :location_id => "1")
    end

  end
end


