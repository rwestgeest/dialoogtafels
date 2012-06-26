require 'spec_helper'

describe City::RegistrationsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  let(:conversation) { FactoryGirl.create :conversation, :location => location }
  alias_method :create_conversation, :conversation
  let(:location) { FactoryGirl.create :location }
  alias_method :create_location, :location
  let(:person) { FactoryGirl.create :person }
  alias_method :create_person, :person
  let(:conversation_leader) { FactoryGirl.create :conversation_leader, person: person, :conversation => conversation }
  alias_method :create_conversation_leader, :conversation_leader

  describe "GET 'index'" do
    context "without person as person parameter" do
      before { create_person; get :index }
      it "assigns all conversation leaders as attendees" do
        assigns(:people).should include(person)
      end
      it "asks for attendee selection" do
        response.should be_success
        response.body.should include(I18n.t("city.registrations.index.select_attendee"))
      end
    end
    context "with person as attendee parameter" do
      before do 
        create_conversation
        get :index , :person_id => person.to_param
      end
      it "assigns the person and locations" do
        assigns(:person).should == person
        assigns(:active_contributions).should == [conversation_leader]
        assigns(:available_locations).should == [location]
      end
      it "renders conversations" do
        response.should be_success
        response.body.should have_selector("#available_conversation_#{conversation.id}")
      end
    end
  end

  describe "POST create" do
    let(:conversation_leader) { FactoryGirl.create :conversation_leader }
    alias_method :create_conversation_leader, :conversation_leader


    describe "with valid params" do
      before { create_conversation; create_conversation_leader }
      def do_post(type_of_contribution = 'conversation_leader')
        xhr :post, :create, {:conversation_id => conversation.to_param, :person_id => person.to_param, :contribution => type_of_contribution}
      end

      describe "for conversation_leader" do
        it "creates a new conversation_leader" do
          expect {
            do_post
          }.to change(ConversationLeader, :count).by(1)
        end
      end

      describe "for participant" do
        it "creates a new participant" do
          expect {
            do_post('participant')
          }.to change(Participant, :count).by(1)
        end
      end

      describe "for organizer" do
        it "creates nothing" do
          expect {
            do_post('organizer')
          }.not_to change(Contributor, :count)
        end
      end

      it "assigns the person" do
        do_post
        assigns(:person).should == person
      end

      it "deregistered conversation is removed from the available list for that location" do
        do_post
        assigns(:location).should == conversation.location
        assigns(:location).available_conversations_for(person).should_not include(conversation)
      end

      it "renders the index partial" do
        do_post
        response.should render_template 'create'
        response.should render_template '_location'
        response.should render_template '_registered_conversations'
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        create_conversation
        xhr :post, :create, {:conversation_id => "bogus", :person_id => person.to_param, :contribution => 'conversation_leader'}
      end

      it "assigns the conversation leader" do
        assigns(:person).should == person
      end

      it "re-renders the 'index' template" do
        should respond_with(404)
      end
    end
  end

  describe "DELETE destroy" do
    before do
      create_conversation_leader
    end

    describe "with valid params" do
      def do_post
        xhr :delete, :destroy, id: conversation_leader
      end
      it "removes a registration" do
        expect {
          do_post
        }.to change(ConversationLeader, :count).by(-1)
      end

      it "assigns the person" do
        do_post
        assigns(:person).should == person
      end

      it "renders the delete partial" do
        do_post
        response.should render_template 'create'
        response.should render_template '_location'
        response.should render_template '_registered_conversations'
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        xhr :delete, :destroy, id: "bogus"
      end

      it "assigns the conversation leader" do
        assigns(:person).should == nil
      end

      it "renders not found" do
        should respond_with(:not_found)
      end
    end
  end
end
