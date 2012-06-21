require "spec_helper"

describe City::CommentsController do
  describe "routing" do

    it "routes to #index" do
      get("/city/comments").should route_to("city/comments#index")
    end

    it "routes to #create" do
      post("/city/comments").should route_to("city/comments#create")
    end

  end
end


