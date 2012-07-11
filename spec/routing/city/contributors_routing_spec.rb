require "spec_helper"

describe City::ContributorsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/locations/1/contributors").should route_to("city/contributors#index", :location_id => "1")
    end

  end
end


