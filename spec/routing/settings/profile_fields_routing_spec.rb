require "spec_helper"

describe Settings::ProfileFieldsController do
  describe "routing" do

    it "routes to #index" do
      get("/settings/profile_fields").should route_to("settings/profile_fields#index")
    end

    it "routes to #new" do
      get("/settings/profile_fields/new").should route_to("settings/profile_fields#new")
    end

    it "routes to #edit" do
      get("/settings/profile_fields/1/edit").should route_to("settings/profile_fields#edit", :id => "1")
    end

    it "routes to #create" do
      post("/settings/profile_fields").should route_to("settings/profile_fields#create")
    end

    it "routes to #update" do
      put("/settings/profile_fields/1").should route_to("settings/profile_fields#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/settings/profile_fields/1").should route_to("settings/profile_fields#destroy", :id => "1")
    end

  end
end
