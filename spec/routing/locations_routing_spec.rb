require 'spec_helper'

describe LocationsController do
  describe "routing" do

    it "routes to #index" do
      get("/locations").should route_to("locations#index")
    end

    it "routes to #index for participants" do
      get("/locations/participants").should route_to("locations#participants")
    end

    it "routes to #index for conversation_leaders" do
      get("/locations/conversation_leaders").should route_to("locations#conversation_leaders")
    end

    it "routes to #show" do
      get("/locations/1").should route_to("locations#show", :id => "1")
    end

  end
end
