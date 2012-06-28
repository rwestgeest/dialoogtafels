require 'spec_helper'
describe City::TrainingInvitationsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/trainings/1/training_invitations").should route_to("city/training_invitations#index", :training_id => "1")
    end

    it "routes to #create" do
      post("/city/trainings/1/training_invitations").should route_to("city/training_invitations#create", :training_id => "1")
    end

  end

end

