require "spec_helper"

describe City::MailingMessagesController do
  describe "routing" do

    it "routes to #index" do
      get("/city/mailing_messages").should route_to("city/mailing_messages#index")
    end

    it "routes to #show" do
      get("/city/mailing_messages/1").should route_to("city/mailing_messages#show", :id => "1")
    end

    it "routes to #create" do
      post("/city/mailing_messages").should route_to("city/mailing_messages#create")
    end

  end
end
