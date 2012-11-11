require 'spec_helper'

describe Messenger do
  let!(:postman)  { mock(Postman) }
  let(:messenger) { Messenger.new postman, tenant } 
  let(:active_project) { tenant.active_project } 
  let(:tenant) { Tenant.current }

  describe "used as class" do
    it "creates an instance with a postman and the current tenant and fires the message" do
      Messenger.any_instance.should_receive(:new_organizer).with('organizer')
      Messenger.new_organizer('organizer')
    end
  end

  describe "notify_new_organizer" do
    prepare_scope :tenant
    let!(:person) { FactoryGirl.build :person }
    let(:notification_emails) { tenant.notification_emails } 

    it "delivers notification emails " do
      postman.should_receive(:deliver).with(:organizer_confirmation, person, tenant.active_project)
      postman.should_receive(:deliver).with(:notify_new_registration, tenant.notification_emails, person, tenant.active_project, :organizer)
      messenger.new_organizer(person)
    end

    context "without email notification list" do
      before do 
        postman.stub(:deliver)
        tenant.notification_emails = ''
      end
      it "does not send a notification to the empty mailing list" do
        postman.should_not_receive(:deliver).with(:notify_new_registration, tenant.notification_emails, person, tenant.active_project, :organizer)
        messenger.new_organizer(person)
      end
    end
  end

  describe "notify new tenant" do
    prepare_scope :tenant
    let(:new_tenant) { FactoryGirl.create :tenant }

    it "first coordinator account is not nil" do
      new_tenant.coordinator_accounts.first.should_not be_nil
    end

    it "delivers an account confirmation and a tenant_creation confirmation to the first coordinator" do
      postman.should_receive(:deliver).with(:tenant_creation, new_tenant)
      postman.should_receive(:deliver).with(:coordinator_confirmation, new_tenant.coordinator_accounts.first)
      messenger.new_tenant(new_tenant)
    end

    describe "notify completed migration" do
      attr_reader :organizers, :coordinators
      before do
        for_tenant new_tenant do
          @organizers = [FactoryGirl.create(:organizer), FactoryGirl.create(:organizer)]
          @coordinators = new_tenant.coordinator_accounts + [FactoryGirl.create(:coordinator_account)]
        end
      end
      it "delivers a nofification to the coordinators and organizers" do
        for_tenant new_tenant do
          postman.should_receive(:deliver).with(:migration_completed_for_organizer, @organizers[0].person)
          postman.should_receive(:deliver).with(:migration_completed_for_organizer, @organizers[1].person)
          postman.should_receive(:deliver).with(:migration_completed_for_coordinator, @coordinators[0])
          postman.should_receive(:deliver).with(:migration_completed_for_coordinator, @coordinators[1])
        end
        messenger.migration_completed(new_tenant)
      end
    end

  end

  describe "conversation registration messages" do
    let!(:organizer) { FactoryGirl.create :organizer }
    let!(:location) { FactoryGirl.create :location, organizer: organizer } 
    let!(:conversation) { FactoryGirl.create :conversation, location: location }
    let(:person) { FactoryGirl.create :person }

    describe "notify new participant" do
      prepare_scope :tenant

      it "has notification emails" do
        tenant.notification_emails.should_not be_empty
      end
      it "confirms participant and notifies organizer" do
        postman.should_receive(:deliver).with(:new_participant, organizer, person, conversation)
        postman.should_receive(:deliver).with(:participant_confirmation, person, active_project)
        postman.should_receive(:deliver).with(:notify_new_registration, tenant.notification_emails, person, tenant.active_project, :participant)
        messenger.new_participant(person, conversation)
      end

      context "without email notification list" do
        before do 
          tenant.notification_emails = ''
        end
        it "does not send a notification to the empty mailing list" do
          postman.should_receive(:deliver).with(:new_participant, organizer, person, conversation)
          postman.should_receive(:deliver).with(:participant_confirmation, person, active_project)
          messenger.new_participant(person, conversation)
        end
      end
    end

    describe "notify new participant ambition" do
      prepare_scope :tenant

      it "confirms participant " do
        postman.should_receive(:deliver).with(:participant_confirmation, person, active_project)
        postman.should_receive(:deliver).with(:notify_new_registration, tenant.notification_emails, person, tenant.active_project, :participant_ambition)
        messenger.new_participant_ambition(person)
      end

      context "without email notification list" do
        before do 
          tenant.notification_emails = ''
        end
        it "does not send a notification to the empty mailing list" do
          postman.should_receive(:deliver).with(:participant_confirmation, person, active_project)
          messenger.new_participant_ambition(person)
        end
      end

    end

    describe "notify new conversation leader" do
      prepare_scope :tenant

      it "confirms conversation_leader and notifies organizer" do
        postman.should_receive(:deliver).with(:new_conversation_leader, organizer, person, conversation)
        postman.should_receive(:deliver).with(:conversation_leader_confirmation, person, active_project)
        postman.should_receive(:deliver).with(:notify_new_registration, tenant.notification_emails, person, tenant.active_project, :conversation_leader)
        messenger.new_conversation_leader(person, conversation)
      end

      context "without email notification list" do
        before do 
          tenant.notification_emails = ''
        end
        it "does not send a notification to the empty mailing list" do
          postman.should_receive(:deliver).with(:new_conversation_leader, organizer, person, conversation)
          postman.should_receive(:deliver).with(:conversation_leader_confirmation, person, active_project)
          messenger.new_conversation_leader(person, conversation)
        end
      end
    end

    describe "notify new conversation leader ambition" do
      prepare_scope :tenant

      it "confirms conversation_leader" do
        postman.should_receive(:deliver).with(:conversation_leader_confirmation, person, active_project)
        postman.should_receive(:deliver).with(:notify_new_registration, tenant.notification_emails, person, tenant.active_project, :conversation_leader_ambition)
        messenger.new_conversation_leader_ambition(person)
      end

      context "without email notification list" do
        before do 
          tenant.notification_emails = ''
        end
        it "does not send a notification to the empty mailing list" do
          postman.should_receive(:deliver).with(:conversation_leader_confirmation, person, active_project)
          messenger.new_conversation_leader_ambition(person)
        end
      end
    end
  end

end
