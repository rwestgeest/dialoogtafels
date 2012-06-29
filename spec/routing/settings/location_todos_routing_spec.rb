require 'spec_helper'

describe Settings::LocationTodosController do
  describe "routing" do

    it "routes to #edit" do
      get("/settings/location_todos/1/edit").should route_to("settings/location_todos#edit", :id => "1")
    end

    it "routes to #create" do
      post("/settings/location_todos").should route_to("settings/location_todos#create")
    end

    it "routes to #update" do
      put("/settings/location_todos/1").should route_to("settings/location_todos#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/settings/location_todos/1").should route_to("settings/location_todos#destroy", :id => "1")
    end

  end
end
