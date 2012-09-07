require 'spec_helper'

describe Messenger do
  let!(:postman)  { mock(Postman) }
  let(:messenger) { Messenger.new postman, tenant } 
  let(:tenant) { Tenant.current }
  let(:active_project) { tenant.active_project } 
  prepare_scope :tenant

  describe "used as class" do
    it "creates an instance with a postman and the current tenant and fires the message" do
      Messenger.any_instance.should_receive(:new_organizer).with('organizer')
      Messenger.new_organizer('organizer')
    end
  end

  describe "notify_new_organizer" do
    let!(:organizer) { FactoryGirl.build :organizer }
    it "delivers an confirmation to the organizer" do
      postman.should_receive(:deliver).with(:organizer_confirmation, organizer, tenant.active_project)
      messenger.new_organizer(organizer)
    end
    it "delivers a notification to the coordinators" do
      pending "implement whe nwe have coordinators mailing list setting" 
    end
  end

  describe "notify new tenant" do
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
          postman.should_receive(:deliver).with(:migration_completed_for_organizer, @organizers[0])
          postman.should_receive(:deliver).with(:migration_completed_for_organizer, @organizers[1])
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

      it "confirms participant and notifies organizer" do
        postman.should_receive(:deliver).with(:new_participant, organizer, person, conversation)
        postman.should_receive(:deliver).with(:participant_confirmation, person, active_project)
        messenger.new_participant(person, conversation)
      end

      it "deliers a notificcation to the coordinators" do
        pending "implement when we have coordinators mailing list setting" 
      end
    end

    describe "notify new participant ambition" do

      it "confirms participant " do
        postman.should_receive(:deliver).with(:participant_confirmation, person, active_project)
        messenger.new_participant_ambition(person)
      end

      it "deliers a notificcation to the coordinators" do
        pending "implement when we have coordinators mailing list setting" 
      end
    end

    describe "notify new conversation leader" do

      it "confirms conversation_leader and notifies organizer" do
        postman.should_receive(:deliver).with(:new_conversation_leader, organizer, person, conversation)
        postman.should_receive(:deliver).with(:conversation_leader_confirmation, person, active_project)
        messenger.new_conversation_leader(person, conversation)
      end

      it "deliers a notificcation to the coordinators" do
        pending "implement when we have coordinators mailing list setting" 
      end
    end

    describe "notify new conversation leader ambition" do

      it "confirms conversation_leader" do
        postman.should_receive(:deliver).with(:conversation_leader_confirmation, person, active_project)
        messenger.new_conversation_leader_ambition(person)
      end

      it "deliers a notificcation to the coordinators" do
        pending "implement when we have coordinators mailing list setting" 
      end
    end
  end

end
