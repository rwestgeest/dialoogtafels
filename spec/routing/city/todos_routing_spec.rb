require "spec_helper"

describe City::TodosController do
  describe "routing" do
    it "routes to #index" do
      get("/city/locations/1/todos").should route_to("city/todos#index", :location_id => "1")
    end

    it "routes to #update" do
      put("/city/locations/2/todos/1").should route_to("city/todos#update", :location_id => "2", :id => "1")
    end
  end
end


