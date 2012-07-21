require 'spec_helper'

describe Registration::ConversationLeadersController do
  render_views
  prepare_scope :tenant

  let(:conversation) { FactoryGirl.create :conversation }

  def valid_attributes
    @valid_attributes ||= FactoryGirl.attributes_for(:conversation_leader, conversation_id: conversation.to_param).stringify_keys
  end

  describe "GET new" do
    it "assigns a new person as @person" do
      get :new, :conversation_id => conversation.to_param
      assigns(:conversation_leader).should be_a_new(ConversationLeader)
      assigns(:conversation_leader).conversation.should == conversation
    end
    it "puts the conversation_id in a hidden field" do
      get :new, :conversation_id => conversation.to_param
      response.body.should have_selector "input[name='conversation_leader[conversation_id]'][type='hidden']"
    end
    it "renders not found when conversation_id not given" do
      get(:new) 
      should respond_with(404)
    end
  end

  describe "GET confirm" do
    login_as :conversation_leader
    let!(:participant) { FactoryGirl.create :participant, person: current_account.person }
    let(:conversations_where_i_participate) { current_account.person.conversations_participating_in_as_participant }
    let(:conversations_which_i_lead ) { current_account.person.conversations_participating_in }
    let(:conversations) { (conversations_where_i_participate + conversations_which_i_lead).uniq }
    let(:locations) { conversations.map {|c| c.location} }

    it "returns http success" do
      get 'confirm'
      response.should be_success
    end
    it "assigns the conversations" do
      get 'confirm'
      assigns(:conversations).sort.should == conversations.sort
    end
    it "renders the location" do
      get 'confirm' 
      locations.each do  |location |
        response.body.should include(location.name)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new conversation_leader" do
        expect {
          post :create, {:conversation_leader => valid_attributes}
        }.to change(ConversationLeader, :count).by(1)
      end

      it "assigns a newly created person as @conversation_leader" do
        post :create, {:conversation_leader => valid_attributes}
        assigns(:conversation_leader).should be_a(ConversationLeader)
        assigns(:conversation_leader).should be_persisted
      end

      it "is associated with the conversation" do
        post :create, {:conversation_leader => valid_attributes}
        conversation.conversation_leaders.should include ConversationLeader.last
      end

      it "signs in an redirects to contributors first_landing_page" do
        post :create, {:conversation_leader => valid_attributes}
        flash.notice.should == I18n.t('.registration.conversation_leaders.welcome')
        current_account.should == Account.last
        response.should redirect_to confirm_registration_conversation_leaders_path
      end
      it "creates a notification for the registration" do
        ConversationLeader.any_instance.should_receive(:save_with_notification)
        post :create, conversation_leader: valid_attributes
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        ConversationLeader.any_instance.stub(:save_with_notification).and_return(false)
        post :create, {:conversation_leader => valid_attributes}
      end
      it "assigns a newly created but unsaved person as @person" do
        assigns(:conversation_leader).should be_a_new(ConversationLeader)
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
      end
    end

    it_should_behave_like "a_captcha_handler", :conversation_leader
  end

end
