require "spec_helper"

describe City::TrainingsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/training_registrations").should route_to("city/training_registrations#index")
    end

    it "routes to #show" do
      get("/city/training_registrations/1").should route_to("city/training_registrations#show", :id => "1")
    end

    it "routes to #create" do
      post("/city/training_registrations").should route_to("city/training_registrations#create")
    end

    it "routes to #destroy" do
      delete("/city/training_registrations/1").should route_to("city/training_registrations#destroy", :id => "1")
    end

  end
end

