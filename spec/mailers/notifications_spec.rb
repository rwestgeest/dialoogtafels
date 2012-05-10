require "spec_helper"

describe Notifications do
  prepare_scope :tenant
  let(:account) { FactoryGirl.create :account } 
  describe "account_reset" do
    let(:mail) { Notifications.account_reset account }

    it "renders the headers" do
      mail.subject.should eq("Account reset")
      mail.to.should eq([account.email])
      mail.from.should eq([Tenant.current.from_email])
    end

    it "puts the response url in the body" do
      mail.body.encoded.should include(account_response_session_url(account.perishable_token, :host => Tenant.current.host))
    end
  end

  describe "account_welcome" do
    let(:mail) { Notifications.account_welcome account }

    it "renders the headers" do
      mail.subject.should eq("Account welcome")
      mail.to.should eq([account.email])
      mail.from.should eq([Tenant.current.from_email])
    end
    it "puts the response url in the body" do
      mail.body.encoded.should include(account_response_session_url(account.perishable_token, :host => Tenant.current.host))
    end

  end

end
