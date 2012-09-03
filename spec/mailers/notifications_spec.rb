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

  shared_examples_for "an_application_confirmation_mail_body" do
    subject { mail.body.encoded }
    it { should include(applicant.name) }
    it { should include(applicant.email) }
    it { should include(applicant.telephone) }

    context "when Profile field exists" do
      let!(:profile_field) { FactoryGirl.create :profile_string_field, field_name: 'address' }
      before { applicant.person.update_attribute :profile_address, 'adres' }
      it { should_not include(profile_field.label) }
      it { should_not include(applicant.person.profile_address) }

      context "and is in form" do
        before { profile_field.update_attribute :on_form, true }
        it { should include(profile_field.label) }
        it { should include(applicant.person.profile_address) }
      end

    end
  end

  describe "participant_confirmation" do
    let(:participant) { FactoryGirl.create :participant }
    let(:mail) { Notifications.participant_confirmation participant, Tenant.current }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.participant_confirmation.subject"))
      mail.to.should eq([participant.email])
      mail.from.should eq([participant.tenant.from_email])
    end

    it "puts the confirmation text in the body" do
      mail.body.encoded.should include_marked_up(Tenant.current.participant_confirmation_text)
    end

    it "puts the confirmation plain text in the body" do
      mail.body.encoded.should include_plain(Tenant.current.participant_confirmation_text)
    end

    it_should_behave_like "an_application_confirmation_mail_body" do
      let(:applicant) { participant }
    end

  end

  describe "conversation_leader_confirmation" do
    let(:conversation_leader) { FactoryGirl.create :conversation_leader }
    let(:mail) { Notifications.conversation_leader_confirmation conversation_leader, Tenant.current }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.conversation_leader_confirmation.subject"))
      mail.to.should eq([conversation_leader.email])
      mail.from.should eq([conversation_leader.tenant.from_email])
    end

    it "puts the confirmation text in the body" do
      mail.body.encoded.should include_marked_up(Tenant.current.conversation_leader_confirmation_text)
    end

    it "puts the confirmation plain text in the body" do
      mail.body.encoded.should include_plain(Tenant.current.conversation_leader_confirmation_text)
    end

    it_should_behave_like "an_application_confirmation_mail_body" do
      let(:applicant) { conversation_leader }
    end

  end

  describe "comment notification" do
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
    let(:mail) { Notifications.new_participant organizer, participant }
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
    let(:mail) { Notifications.new_conversation_leader organizer, conversation_leader }

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

  RSpec::Matchers.define :include_marked_up do |expected|
    match do |actual|
      actual.gsub("\r\n", '').include?(marked_up(expected).gsub("\n", ''))
    end
    failure_message_for_should do |actual| 
      "expected that #{actual} matches #{marked_up(expected)}"
    end
  end

  RSpec::Matchers.define :include_plain do |expected|
    match do |actual|
      actual.gsub("\r\n", '').include?(expected.gsub("\n", ''))
    end
    failure_message_for_should do |actual| 
      "expected that #{actual} matches #{marked_up(expected)}"
    end
  end

  def marked_up(text)
    BlueCloth.new(text).to_html
  end
end
