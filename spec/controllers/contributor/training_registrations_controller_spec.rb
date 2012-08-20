require 'spec_helper'

describe Contributor::TrainingRegistrationsController do
  render_views
  prepare_scope :tenant
  login_as :conversation_leader

  let(:training) { FactoryGirl.create :training }
  alias_method :create_training, :training

  let(:training_type) { training.training_type }

  let(:person) { current_account.person }

  describe "GET 'show'" do
    before {  create_training }
    def do_get 
      get :show
    end

    it "assigns the conversation leader and trainings" do
      do_get
      assigns(:attendee).should == person
      assigns(:training_types).should == [training_type]
    end

    it "renders trainings" do
      do_get
      response.should be_success
      response.body.should have_selector("#training_#{training.id}")
    end

    context "full trainings" do
      it "are not rendered in available" do
        Training.update_counters training, :participant_count => training.max_participants
        do_get
        response.body.should_not have_selector("#training_#{training.id}")
      end
    end
  end

  def valid_attributes
    { training_type.to_param => training.to_param }
  end

  describe "PUT update" do
    describe "with valid params" do
      def do_put
        put(:update, :training_registrations => valid_attributes)
      end
      it "creates a new training_registration" do
        expect {
          do_put
        }.to change(TrainingRegistration, :count).by(1)
      end

      it "redirects to show" do
        do_put
        response.should redirect_to(contributor_training_registrations_path)
      end
    end
  end
end
