require "spec_helper"

describe City::TrainingsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/training_types/33/trainings").should route_to("city/trainings#index", :training_type_id => "33")
    end

    it "routes to #new" do
      get("/city/training_types/33/trainings/new").should route_to("city/trainings#new", :training_type_id => "33")
    end

    it "routes to #edit" do
      get("/city/training_types/33/trainings/1/edit").should route_to("city/trainings#edit", :id => "1", :training_type_id => "33")
    end

    it "routes to #create" do
      post("/city/training_types/33/trainings").should route_to("city/trainings#create", :training_type_id => "33")
    end

    it "routes to #update" do
      put("/city/training_types/33/trainings/1").should route_to("city/trainings#update", :id => "1", :training_type_id => "33")
    end

    it "routes to #destroy" do
      delete("/city/training_types/33/trainings/1").should route_to("city/trainings#destroy", :id => "1", :training_type_id => "33")
    end

  end
end
