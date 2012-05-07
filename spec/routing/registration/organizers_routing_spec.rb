require "spec_helper"

describe Registration::OrganizersController do
  describe "routing" do

    it "routes to #new" do
      get("/registration/organizers/new").should route_to("registration/organizers#new")
    end

    it "routes to #create" do
      post("/registration/organizers").should route_to("registration/organizers#create")
    end

  end
end
