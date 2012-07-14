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

  describe "comment notific<ation" do
    let(:location_comment) { FactoryGirl.create :location_comment, subject: "my comment", body: "#Header\nbody" }
    let(:person) { FactoryGirl.create :person, email: "addressee@example.com"  }
    let(:mail) { Notifications.new_comment location_comment, person }

    it "renders the headers" do
      mail.subject.should eq(location_comment.subject)
      mail.from.should eq([ person.tenant.from_email ])
      mail.to.should eq([ person.email ])
    end

    it "puts the body marked up in the bdy" do
      mail.body.encoded.should have_selector("h1")
      mail.body.encoded.should include("Header")
      mail.body.encoded.should include("body")
    end

    it "has a link to the comment" do
      mail.body.encoded.should have_selector("a[href='#{city_location_comment_url(location_comment.to_param, :location_id => location_comment.reference_id, :host => Tenant.current.host)}']")
    end

  end

  describe "training invitation" do
    let(:training_invitation) { FactoryGirl.create :training_invitation, subject: "invitation", body: "#Header\nbody" }
    let(:person) { FactoryGirl.create :person, email: "addressee@example.com"  }
    let(:mail) { Notifications.new_training_invitation training_invitation, person }

    it "renders the headers" do
      mail.subject.should eq(training_invitation.subject)
      mail.from.should eq([ person.tenant.from_email ])
      mail.to.should eq([ person.email ])
    end

    it "puts the body marked up in the bdy" do
      mail.body.encoded.should have_selector("h1")
      mail.body.encoded.should include("Header")
      mail.body.encoded.should include("body")
    end

  end

  describe "new_participant" do
    let(:conversation) { FactoryGirl.create :conversation }
    let(:organizer) { conversation.organizer }
    let(:participant) { FactoryGirl.build :participant, conversation: conversation }
    let(:mail) { Notifications.new_participant participant, organizer }
    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.new_participant.subject"))
      mail.to.should eq([organizer.email])
      mail.from.should eq([organizer.tenant.from_email])
    end
    it "renders the organizer and participant names in the body" do
      mail.body.encoded.should include(organizer.name)
      mail.body.encoded.should include(participant.name)
    end
    it "renders a link to the location" do
      mail.body.encoded.should include(city_location_url(conversation.location.to_param, :host => organizer.tenant.host))
    end
  end

  describe "new conversation_leader" do
    let(:conversation) { FactoryGirl.create :conversation }
    let(:organizer) { conversation.organizer }
    let(:conversation_leader) { FactoryGirl.build :conversation_leader, conversation: conversation }
    let(:mail) { Notifications.new_conversation_leader conversation_leader, organizer }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.new_conversation_leader.subject"))
      mail.to.should eq([organizer.email])
      mail.from.should eq([organizer.tenant.from_email])
    end

    it "renders the organizer and conversation_leader names in the body" do
      mail.body.encoded.should include(organizer.name)
      mail.body.encoded.should include(conversation_leader.name)
    end
    it "renders a ling to the location" do
      mail.body.encoded.should include(city_location_url(conversation.location.to_param, :host => organizer.tenant.host))
    end
  end

end
