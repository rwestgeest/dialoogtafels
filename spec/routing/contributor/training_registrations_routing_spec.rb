require "spec_helper"

describe Contributor::TrainingRegistrationsController do
  describe "routing" do

    it "routes to #show" do
      get("/contributor/training_registrations").should route_to("contributor/training_registrations#show")
    end

    it "routes to #update" do
      put("/contributor/training_registrations").should route_to("contributor/training_registrations#update")
    end

  end
end

