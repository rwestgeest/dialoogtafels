require "spec_helper"

describe Admin::TenantsController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/tenants").should route_to("admin/tenants#index")
    end

    it "routes to #new" do
      get("/admin/tenants/new").should route_to("admin/tenants#new")
    end

    it "routes to #show" do
      get("/admin/tenants/1").should route_to("admin/tenants#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/tenants/1/edit").should route_to("admin/tenants#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/tenants").should route_to("admin/tenants#create")
    end

    it "routes to #update" do
      put("/admin/tenants/1").should route_to("admin/tenants#update", :id => "1")
    end

    it "routes to #notify_done" do
      put("/admin/tenants/1/notify_new").should route_to("admin/tenants#notify_new", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/tenants/1").should route_to("admin/tenants#destroy", :id => "1")
    end

  end
end
