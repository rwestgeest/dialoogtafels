require "spec_helper"

describe City::PeopleController do
  describe "routing" do

    it "routes to #index" do
      get("/city/people").should route_to("city/people#index")
    end

    it "routes to #edit" do
      get("/city/people/1/edit").should route_to("city/people#edit", :id => "1")
    end

    it "routes to #index" do
      put("/city/people/1").should route_to("city/people#update", :id => "1")
    end

  end
end


