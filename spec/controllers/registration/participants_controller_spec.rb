require 'spec_helper'

describe Registration::ParticipantsController do
  render_views
  prepare_scope :tenant

  def valid_attributes
    FactoryGirl.attributes_for(:participant).stringify_keys
  end
  
  describe "GET new" do
    it "assigns a new person as @person" do
      get :new, {}
      assigns(:participant).should be_a_new(Participant)
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
      it "assigns a newly created but unsaved person as @person" do
        # Trigger the behavior that occurs when invalid params are submitted
        Participant.any_instance.stub(:save).and_return(false)
        post :create, {:participant => {}}
        assigns(:participant).should be_a_new(Participant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Participant.any_instance.stub(:save).and_return(false)
        post :create, {:participant => {}}
        response.should render_template("new")
      end
    end
  end

end
