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

  shared_examples_for "a_tenant_creation_body" do
    subject { mail.body.encoded } 

    it { should match("td.*#{tenant.name}") }
    it { should match("Stad.*#{tenant.name}") }

    it { should match("td.*#{tenant.representative_name}") }
    it { should match("Naam.*#{tenant.representative_name}") }

    it { should match("td.*#{tenant.representative_email}") }
    it { should match("Email.*#{tenant.representative_email}") }

    it { should match("td.*#{tenant.representative_telephone}") }
    it { should match("Telefoon.*#{tenant.representative_telephone}") }

    it { should match("td.*#{tenant.invoice_address}") }
    it { should match("Factuuradres.*#{tenant.invoice_address}") }

    it { should match("td.*#{tenant.site_url}") }
    it { should match("Dialoogsite.*#{tenant.site_url}") }

    it { should match("td.*#{tenant.host}") }
    it { should match("Dialoogtafels url.*#{tenant.host}") }

    it { should match("td.*#{tenant.info_email}") }
    it { should match("Info email.*#{tenant.info_email}") }

    it { should match("td.*#{tenant.from_email}") }
    it { should match("Afzender email.*#{tenant.from_email}") }

    it { should match("td.*#{tenant.public_style_sheet}") }
    it { should match("Stylesheet.*#{tenant.public_style_sheet}") }

    it { should match("td.*#{tenant.top_image}") }
    it { should match("Header plaatje.*#{tenant.top_image}") }

    it { should match("td.*#{tenant.right_image}") }
    it { should match("Rechter kantlijn.*#{tenant.right_image}") }

    it { should have_selector("a[href='#{root_url(:host => tenant.host)}']") }

    it { should have_selector("a[href='#{new_registration_organizer_url(:host => tenant.host)}']") }
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

  describe "tenant_creation" do
    let(:tenant) { FactoryGirl.create :tenant }
    let(:mail) { Notifications.tenant_creation tenant }
    let(:addressee) { tenant.representative_email }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.tenant_creation.subject."))
      mail.to.should eq([addressee])
      mail.from.should eq([Notifications::DialoogTafelsMail])
    end
    it_should_behave_like "a_tenant_creation_body"
  end

  describe "migration_completed_for_organizer" do
    let(:organizer) { FactoryGirl.create :organizer }
    let(:mail) { Notifications.migration_completed_for_organizer organizer }
    let(:tenant) { organizer.tenant }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.migration_completed_for_organizer.subject."))
      mail.to.should eq([organizer.email])
      mail.cc.should eq([tenant.info_email])
      mail.from.should eq([Notifications::DialoogTafelsMail])
    end

    it "should render the account confirmation link" do
      mail.body.encoded.should include(account_response_session_url(organizer.account.authentication_token, :host => tenant.host))
    end

    it_should_behave_like "an_application_confirmation_mail_body" do
      let(:applicant) { organizer }
    end
  end

  describe "migration_completed_for_coordinator" do
    let(:coordinator) { FactoryGirl.create :coordinator_account }
    let(:mail) { Notifications.migration_completed_for_coordinator coordinator }
    let(:tenant) { coordinator.tenant }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.migration_completed_for_coordinator.subject."))
      mail.to.should eq([coordinator.email])
      mail.from.should eq([Notifications::DialoogTafelsMail])
    end

    it "should render the account confirmation link" do
      mail.body.encoded.should include(account_response_session_url(coordinator.authentication_token, :host => tenant.host))
    end

    it_should_behave_like "a_tenant_creation_body" 
  end

  describe "participant_confirmation" do
    let(:participant) { FactoryGirl.create :participant }
    let(:mail) { Notifications.participant_confirmation participant, active_project }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.participant_confirmation.subject"))
      mail.to.should eq([participant.email])
      mail.from.should eq([participant.tenant.from_email])
    end

    it "puts the confirmation text in the body" do
      mail.body.encoded.should include_marked_up(active_project.participant_confirmation_text)
    end

    it "puts the confirmation plain text in the body" do
      mail.body.encoded.should include_plain(active_project.participant_confirmation_text)
    end

    it_should_behave_like "an_application_confirmation_mail_body" do
      let(:applicant) { participant }
    end

  end

  describe "conversation_leader_confirmation" do
    let(:conversation_leader) { FactoryGirl.create :conversation_leader }
    let(:mail) { Notifications.conversation_leader_confirmation conversation_leader, active_project }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.conversation_leader_confirmation.subject"))
      mail.to.should eq([conversation_leader.email])
      mail.from.should eq([conversation_leader.tenant.from_email])
    end

    it "puts the confirmation text in the body" do
      mail.body.encoded.should include_marked_up(active_project.conversation_leader_confirmation_text)
    end

    it "puts the confirmation plain text in the body" do
      mail.body.encoded.should include_plain(active_project.conversation_leader_confirmation_text)
    end

    it_should_behave_like "an_application_confirmation_mail_body" do
      let(:applicant) { conversation_leader }
    end

  end

  describe "organizer_confirmation" do
    let(:organizer) { FactoryGirl.create :organizer }
    let(:mail) { Notifications.organizer_confirmation organizer, active_project }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.organizer_confirmation.subject"))
      mail.to.should eq([organizer.email])
      mail.from.should eq([organizer.tenant.from_email])
    end

    it "should render the account confirmation link" do
      mail.body.encoded.should include(account_response_session_url(organizer.account.authentication_token, :host => current_tenant.host))
    end

    it "puts the confirmation text in the body" do
      mail.body.encoded.should include_marked_up(active_project.organizer_confirmation_text)
    end

    it "puts the confirmation plain text in the body" do
      mail.body.encoded.should include_plain(active_project.organizer_confirmation_text)
    end

    it_should_behave_like "an_application_confirmation_mail_body" do
      let(:applicant) { organizer }
    end
  end

  describe "coordinator_confirmation" do
    let(:coordinator) { FactoryGirl.create :coordinator_account }
    let(:mail) { Notifications.coordinator_confirmation coordinator }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.coordinator_confirmation.subject"))
      mail.to.should eq([coordinator.email])
      mail.from.should eq([coordinator.tenant.from_email])
    end

    it "should render the account confirmation link" do
      mail.body.encoded.should include(account_response_session_url(coordinator.authentication_token, :host => current_tenant.host))
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
      mail.body.encoded.should have_selector("a[href='#{city_location_comment_url(location_comment.to_param, :location_id => location_comment.reference_id, :host => current_tenant.host)}']")
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
    let(:person) { FactoryGirl.build :person }
    let(:mail) { Notifications.new_participant organizer, person, conversation }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.new_participant.subject"))
      mail.to.should eq([organizer.email])
      mail.from.should eq([organizer.tenant.from_email])
    end
    it "renders the organizer and person names in the body" do
      mail.body.encoded.should include(organizer.name)
      mail.body.encoded.should include(person.name)
    end
    it "renders a link to the location" do
      mail.body.encoded.should include(city_location_url(conversation.location.to_param, :host => organizer.tenant.host))
    end

  end

  describe "new conversation_leader" do
    let(:conversation) { FactoryGirl.create :conversation }
    let(:organizer) { conversation.organizer }
    let(:person) { FactoryGirl.build :person }
    let(:mail) { Notifications.new_conversation_leader organizer, person, conversation }

    it "renders the headers" do
      mail.subject.should eq(I18n.t("notifications.new_conversation_leader.subject"))
      mail.to.should eq([organizer.email])
      mail.from.should eq([organizer.tenant.from_email])
    end

    it "renders the organizer and conversation_leader names in the body" do
      mail.body.encoded.should include(organizer.name)
      mail.body.encoded.should include(person.name)
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

  def current_tenant
    Tenant.current
  end
  def active_project
    current_tenant.active_project
  end
end
