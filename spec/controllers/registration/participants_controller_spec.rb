require 'spec_helper'

describe Registration::ParticipantsController do
  render_views
  prepare_scope :tenant

  let(:conversation) { FactoryGirl.create :conversation }

  def valid_attributes
    @valid_attributes ||= FactoryGirl.attributes_for(:participant, conversation_id: conversation.to_param).stringify_keys
  end

  describe "GET new" do
    it "assigns a new person as @person" do
      get :new, :conversation_id => conversation.to_param
      assigns(:participant).should be_a_new(Participant)
      assigns(:participant).conversation.should == conversation
    end
    it "puts the conversation_id in a hidden field" do
      get :new, :conversation_id => conversation.to_param
      response.body.should have_selector "input[name='participant[conversation_id]'][type='hidden']"
    end
    it "renders not found when conversation_id not given" do
      get(:new) 
      should respond_with(404)
    end
  end
 
  describe "GET conirm" do
    login_as :participant
    let(:contributor) { current_account.highest_contribution}
    let(:conversation) { contributor.conversation }
    let(:location) { conversation.location }

    it "returns http success" do
      get 'confirm'
      response.should be_success
    end
    it "assigns the conversations" do
      pending "should show all conversations"
      get 'confirm'
      assigns(:conversation).should == conversation
    end
    it "renders the location" do
      get 'confirm' 
      response.body.should include(location.name)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new participant" do
        expect {
          post :create, {:participant => valid_attributes}
        }.to change(Participant, :count).by(1)
      end

      it "assigns a newly created person as @person" do
        post :create, {:participant => valid_attributes}
        assigns(:participant).should be_a(Participant)
        assigns(:participant).should be_persisted
      end

      it "signs in and redirects to confirm" do
        post :create, {:participant => valid_attributes}
        flash.notice.should == I18n.t('.registration.participants.welcome')
        current_account.should == Account.last
        response.should redirect_to confirm_registration_participants_url
      end
      it "creates a notification for the registration" do
        Participant.any_instance.should_receive(:save_with_notification)
        post :create, participant: valid_attributes
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Participant.any_instance.stub(:save_with_notification).and_return(false)
        post :create, {:participant => valid_attributes}
      end
      it "assigns a newly created but unsaved person as @person" do
        assigns(:participant).should be_a_new(Participant)
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
      end
    end

    it_should_behave_like "a_captcha_handler", :participant
  end

end
