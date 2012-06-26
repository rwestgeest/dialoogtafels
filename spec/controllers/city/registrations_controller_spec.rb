require 'spec_helper'

describe City::RegistrationsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  let(:conversation) { FactoryGirl.create :conversation, :location => location }
  alias_method :create_conversation, :conversation
  let(:location) { FactoryGirl.create :location }
  alias_method :create_location, :location
  let(:person) { conversation_leader.person }

  describe "GET 'index'" do
    let(:conversation_leader) { FactoryGirl.create :conversation_leader, :conversation => conversation }
    alias_method :create_conversation_leader, :conversation_leader

    before { create_conversation; create_conversation_leader }
    context "without person as person parameter" do
      it "assigns all conversation leaders as attendees" do
        get :index 
        assigns(:people).should include(person)
      end
      it "asks for attendee selection" do
        get :index
        response.should be_success
        response.body.should include(I18n.t("city.registrations.index.select_attendee"))
      end
    end
    context "with person as attendee parameter" do
      def do_get
        get :index , :person_id => person.to_param
      end
      it "assigns the person and locations" do
        do_get
        assigns(:person).should == person
        assigns(:active_contributions).should == [conversation_leader]
        assigns(:available_locations).should == [location]
      end
      it "renders conversations" do
        do_get
        response.should be_success
        response.body.should have_selector("#available_conversation_#{conversation.id}")
      end
    end
  end

  def valid_attributes
    {:conversation_id => conversation.to_param, :person_id => person.to_param, :type => 'conversation_leader'}
  end

  describe "POST create" do
    let(:conversation_leader) { FactoryGirl.create :conversation_leader }
    alias_method :create_conversation_leader, :conversation_leader
    describe "with valid params" do
      before { create_conversation; create_conversation_leader }
      def do_post
        xhr :post, :create, valid_attributes
      end
      it "creates a new training_registration" do
        expect {
          do_post
        }.to change(Contributor, :count).by(1)
      end

      it "assignsthe conversation leader" do
        do_post
        assigns(:person).should == person
      end

      it "renders the index partial" do
        do_post
        response.should render_template 'index'
        response.should render_template '_index'
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        create_conversation
        xhr :post, :create, {:conversation_id => "bogus", :person_id => person.to_param, :type => 'conversation_leader'}
      end

      it "assigns the conversation leader" do
        assigns(:person).should == person
      end

      it "re-renders the 'index' template" do
        response.should render_template("index")
        response.should render_template("_index")
      end
    end
  end

  describe "DELETE destroy" do
    let(:conversation_leader) { FactoryGirl.create :conversation_leader, :conversation => conversation }
    alias_method :create_conversation_leader, :conversation_leader
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

      it "renders the index partial" do
        do_post
        response.should render_template 'index'
        response.should render_template '_index'
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        xhr :delete, :destroy, id: "bogus"
      end

      it "assigns the conversation leader" do
        assigns(:person).should == conversation_leader
      end

      it "renders not found" do
        response.should be(:not_found)
      end
    end
  end
end
