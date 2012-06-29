require 'spec_helper'

describe Settings::ProjectsController do
  describe "routing" do

    it "routes to #edit" do
      get("/settings/project/edit").should route_to("settings/projects#edit")
    end

    it "routes to #update" do
      put("/settings/project").should route_to("settings/projects#update")
    end

  end
end
