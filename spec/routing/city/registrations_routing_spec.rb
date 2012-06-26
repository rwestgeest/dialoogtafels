require "spec_helper"

describe City::RegistrationsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/registrations").should route_to("city/registrations#index")
    end

    it "routes to #create" do
      post("/city/registrations").should route_to("city/registrations#create")
    end

    it "routes to #destroy" do
      delete("/city/registrations/1").should route_to("city/registrations#destroy", :id => "1")
    end

  end
end


