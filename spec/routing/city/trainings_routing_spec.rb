require "spec_helper"

describe City::TrainingsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/trainings").should route_to("city/trainings#index")
    end

    it "routes to #new" do
      get("/city/trainings/new").should route_to("city/trainings#new")
    end

    it "routes to #show" do
      get("/city/trainings/1").should route_to("city/trainings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/city/trainings/1/edit").should route_to("city/trainings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/city/trainings").should route_to("city/trainings#create")
    end

    it "routes to #update" do
      put("/city/trainings/1").should route_to("city/trainings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/city/trainings/1").should route_to("city/trainings#destroy", :id => "1")
    end

  end
end
