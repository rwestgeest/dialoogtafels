require "spec_helper"

describe City::ProjectsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/projects").should route_to("city/projects#index")
    end

    it "routes to #new" do
      get("/city/projects/new").should route_to("city/projects#new")
    end

    it "routes to #show" do
      get("/city/projects/1").should route_to("city/projects#show", :id => "1")
    end

    it "routes to #edit" do
      get("/city/projects/1/edit").should route_to("city/projects#edit", :id => "1")
    end

    it "routes to #create" do
      post("/city/projects").should route_to("city/projects#create")
    end

    it "routes to #update" do
      put("/city/projects/1").should route_to("city/projects#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/city/projects/1").should route_to("city/projects#destroy", :id => "1")
    end

  end
end
