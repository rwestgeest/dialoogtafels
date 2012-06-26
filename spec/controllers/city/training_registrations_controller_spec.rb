require 'spec_helper'

describe City::TrainingRegistrationsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  let(:training) { FactoryGirl.create :training }
  alias_method :create_training, :training
  let(:conversation_leader) { FactoryGirl.create :conversation_leader }
  alias_method :create_conversation_leader, :conversation_leader

  describe "GET 'index'" do
    before { create_training; create_conversation_leader }
    context "without conversation leader as attendee parameter" do
      it "assigns all conversation leaders as attendees" do
        get :index 
        assigns(:attendees).should == [conversation_leader]
      end
      it "asks for attendee selection" do
        get :index
        response.should be_success
        response.body.should include(I18n.t("city.training_registrations.index.select_attendee"))
      end
    end
    context "with conversation leader as attendee parameter" do
      def do_get
        get :index , :attendee_id => conversation_leader.to_param
      end
      it "assigns the conversation leader and trainings" do
        do_get
        assigns(:attendee).should == conversation_leader
        assigns(:available_trainings).should == [training]
      end
      it "renders trainings" do
        do_get
        response.should be_success
        response.body.should have_selector("#training_#{training.id}")
      end
      context "registered trainings" do
        it "are not rendered in available" do
          conversation_leader.register_for training
          do_get
          response.body.should_not have_selector("#training_#{training.id}")
        end
      end
    end
  end

  def valid_attributes
    {:training_id => training.to_param, :attendee_id => conversation_leader.to_param}
  end

  describe "POST create" do
    describe "with valid params" do
      def do_post
        xhr :post, :create, valid_attributes
      end
      it "creates a new training_registration" do
        expect {
          do_post
        }.to change(TrainingRegistration, :count).by(1)
      end

      it "assignsthe conversation leader" do
        do_post
        assigns(:attendee).should == conversation_leader
      end
      it "registered training is removed from the available training list" do
        do_post
        assigns(:available_trainings).should == []
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
        create_training
        xhr :post, :create, {:training_id => "bogus", :attendee_id => conversation_leader.to_param}
      end

      it "assigns the conversation leader" do
        assigns(:attendee).should == conversation_leader
      end

      it "still has the training in the available list" do
        assigns(:available_trainings).should == [training]
      end

      it "re-renders the 'index' template" do
        response.should render_template("index")
        response.should render_template("_index")
      end
    end
  end

  describe "DELETE destroy" do
    before do
      conversation_leader.register_for training 
    end

    describe "with valid params" do
      def do_post
        xhr :delete, :destroy, id: training.to_param, :attendee_id => conversation_leader.to_param
      end
      it "removes a training_registration" do
        expect {
          do_post
        }.to change(TrainingRegistration, :count).by(-1)
      end

      it "assignsthe conversation leader" do
        do_post
        assigns(:attendee).should == conversation_leader
      end
      it "deregistered training is added to the available training list" do
        do_post
        assigns(:available_trainings).should == [training]
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
        create_training
        xhr :delete, :destroy, id: "bogus", :attendee_id => conversation_leader.to_param
      end

      it "assigns the conversation leader" do
        assigns(:attendee).should == conversation_leader
      end

      it "still does not have the training in the available list" do
        assigns(:available_trainings).should == []
      end

      it "re-renders the 'index' template" do
        response.should render_template("index")
        response.should render_template("_index")
      end
    end
  end

end