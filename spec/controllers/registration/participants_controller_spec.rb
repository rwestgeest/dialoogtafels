require 'spec_helper'

describe Registration::ParticipantsController do
  render_views
  prepare_scope :tenant

  let(:conversation) { FactoryGirl.create :conversation }

  def valid_attributes
    FactoryGirl.attributes_for(:participant, conversation_id: conversation.to_param).stringify_keys
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

      it "redirects to confirm" do
        post :create, {:participant => valid_attributes}
        flash.notice.should == I18n.t('.registration.participants.welcome')
        response.should redirect_to confirm_registration_participants_url
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Participant.any_instance.stub(:save).and_return(false)
        post :create, {:participant => valid_attributes}
      end
      it "assigns a newly created but unsaved person as @person" do
        assigns(:participant).should be_a_new(Participant)
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
      end
    end
  end

end