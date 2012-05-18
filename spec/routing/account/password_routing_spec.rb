require "spec_helper"

describe Account::PasswordsController do
  describe "routing" do
    it "routes to #edit" do
      get("/account/password/edit").should route_to("account/passwords#edit")
    end
  end
end
