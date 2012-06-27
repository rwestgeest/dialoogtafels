require 'spec_helper'

describe City::TrainingsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  def valid_attributes
    FactoryGirl.attributes_for :training
  end

  let(:training) { FactoryGirl.create :training }
  alias_method :create_training, :training
  let(:conversation_leader) { FactoryGirl.create :conversation_leader }
  alias_method :create_conversation_leader, :conversation_leader
  
  describe "GET index" do
    before {  create_training; create_conversation_leader }
    it "assigns all trainings as @trainings" do
      get :index, {}
      assigns(:trainings).should eq([training])
    end
    it "assigns all conversation_leaders as @conversation_leaders" do
      get :index, {}
      assigns(:conversation_leaders).should eq([conversation_leader.person])
    end
  end

  describe "GET show" do
    it "assigns the requested training as @training" do
      create_training
      get :show, {:id => training.to_param}
      assigns(:training).should eq(training)
    end
  end

  describe "GET new" do
    it "assigns a new training as @training" do
      get :new, {}
      assigns(:training).should be_a_new(Training)
    end
  end

  describe "GET edit" do
    it "assigns the requested training as @training" do
      create_training
      get :edit, {:id => training.to_param}
      assigns(:training).should eq(training)
    end
  end

  describe "POST create" do
    def do_post
      post :create, {:training => valid_attributes}
    end
    describe "with valid params" do
      it "creates a new Training" do
        expect {
          do_post
        }.to change(Training, :count).by(1)
      end

      it "assigns a newly created training as @training" do
        do_post
        assigns(:training).should be_a(Training)
        assigns(:training).should be_persisted
      end

      it "redirects to the created training" do
        do_post
        response.should redirect_to(city_training_path(Training.last))
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Training.any_instance.stub(:save).and_return(false)
        do_post
      end
      it "assigns a newly created but unsaved training as @training" do
        assigns(:training).should be_a_new(Training)
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before { create_training }
    def do_put
      put :update, {:id => training.to_param, :training => valid_attributes}
    end
    describe "with valid params" do
      it "updates the requested training" do
        # Assuming there are no other trainings in the database, this
        # specifies that the Training created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Training.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => training.to_param, :training => {'these' => 'params'}}
      end

      it "assigns the requested training as @training" do
        do_put
        assigns(:training).should eq(training)
      end

      it "redirects to the training" do
        do_put
        response.should redirect_to(city_training_path(training))
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Training.any_instance.stub(:save).and_return(false)
        do_put
      end

      it "assigns the training as @training" do
        assigns(:training).should eq(training)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { create_training }
    it "destroys the requested training" do
      expect {
        delete :destroy, {:id => training.to_param}
      }.to change(Training, :count).by(-1)
    end

    it "redirects to the trainings list" do
      delete :destroy, {:id => training.to_param}
      response.should redirect_to(city_trainings_url)
    end
  end

end
