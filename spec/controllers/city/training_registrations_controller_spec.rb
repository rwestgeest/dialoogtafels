require 'spec_helper'

describe City::TrainingRegistrationsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  let(:training_type) { FactoryGirl.create :training_type }
  alias_method :create_training_type, :training_type
  let(:training) { FactoryGirl.create :training, training_type: training_type }
  alias_method :create_training, :training
  let(:conversation_leader) { FactoryGirl.create :conversation_leader }
  alias_method :create_conversation_leader, :conversation_leader
  let(:person) { conversation_leader.person }
  alias_method :create_person, :create_conversation_leader

  describe "GET 'show'" do
    before { create_training; create_person }

    def do_get
      get :show , :id => person.to_param
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
      it "are not available" do
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
        put :update, :id => person.to_param, :training_registrations => valid_attributes 
      end

      it "creates a new training_registration" do
        expect {
          do_put
        }.to change(TrainingRegistration, :count).by(1)
      end

      it "replaces possible existing registrations" do
        person.register_for FactoryGirl.create :training
        expect {
          do_put
        }.not_to change(TrainingRegistration, :count)
        person.should be_registered_for_training(training.to_param)
      end

      it "redirects to show" do
        do_put
        response.should redirect_to(city_training_registration_path(:id => person.to_param))
      end
    end

  end


end
