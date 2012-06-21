require "spec_helper"

describe Notifications do
  prepare_scope :tenant
  let(:account) { FactoryGirl.create :account } 
  describe "account_reset" do
    let(:mail) { Notifications.account_reset account }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.account_reset.subject."))
      mail.to.should eq([account.email])
      mail.from.should eq([account.tenant.from_email])
    end

    it "puts the response url in the body" do
      mail.body.encoded.should include(account_response_session_url(account.authentication_token, :host => account.tenant.host))
    end
  end

  describe "account_welcome" do
    let(:mail) { Notifications.account_welcome account }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.account_welcome.subject"))
      mail.to.should eq([account.email])
      mail.from.should eq([account.tenant.from_email])
    end
    it "puts the response url in the body" do
      mail.body.encoded.should include(account_response_session_url(account.authentication_token, :host => account.tenant.host))
    end

  end

end
