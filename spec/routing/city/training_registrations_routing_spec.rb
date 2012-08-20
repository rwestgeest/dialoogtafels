require "spec_helper"

describe City::TrainingRegistrationsController do
  describe "routing" do

    it "routes to #show" do
      get("/city/training_registrations/1").should route_to("city/training_registrations#show", :id => '1')
    end

    it "routes to #update" do
      put("/city/training_registrations/1").should route_to("city/training_registrations#update", :id => '1')
    end

  end
end

