require 'spec_helper'

describe Account::SessionsController do
  describe "routing" do
    it "routes to #login" do
      get("/login").should route_to("account/sessions#new")
    end
    it "routes to #maintainer_login" do
      get("/maintainer_login").should route_to("account/sessions#new", :maintainer => 'maintainer')
    end
  end
end

