require "spec_helper"

describe Contributor::TrainingRegistrationsController do
  describe "routing" do

    it "routes to #index" do
      get("/contributor/training_registrations").should route_to("contributor/training_registrations#index")
    end

    it "routes to #create" do
      post("/contributor/training_registrations").should route_to("contributor/training_registrations#create")
    end

    it "routes to #destroy" do
      delete("/contributor/training_registrations/1").should route_to("contributor/training_registrations#destroy", :id => "1")
    end

  end
end

