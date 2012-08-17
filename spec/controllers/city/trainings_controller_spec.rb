require 'spec_helper'

describe City::TrainingsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  def valid_attributes
    FactoryGirl.attributes_for :training
  end

  let(:training_type) { FactoryGirl.create :training_type }

  let(:training) { FactoryGirl.create :training, training_type: training_type}
  alias_method :create_training, :training

  let(:conversation_leader) { FactoryGirl.create :conversation_leader }
  alias_method :create_conversation_leader, :conversation_leader
  
  def with_training_type_scope(request_parameters = {})
    {:training_type_id => training_type.to_param }.merge(request_parameters)
  end

  describe "GET index through ajax" do
    before {  create_training }
    def do_get
      xhr :get, :index, with_training_type_scope
    end
    it "assigns all trainings as @trainings" do
      do_get
      assigns(:trainings).should eq([training])
    end
    it "renders index.js rendering training collection" do
      do_get
      response.should render_template 'index'
      response.should render_template '_index'
    end
  end

  describe "GET show" do
    it "assigns the requested training as @training" do
      create_training
      get :show, with_training_type_scope(:id => training.to_param)
      assigns(:training).should eq(training)
    end
  end

  describe "GET new" do
    before { xhr :get, :new, with_training_type_scope }

    it "assigns a new training as @training" do
      assigns(:training).should be_a_new(Training)
      assigns(:training).training_type_id.should == training_type.id
    end

    it "renders the form through new.js" do
      response.should render_template 'new'
      response.should render_template '_form'
    end
  end

  describe "GET edit" do
    before { create_training; do_get }

    def do_get 
      xhr :get, :edit, with_training_type_scope(:id => training.to_param)
    end

    it "assigns the requested training as @training" do
      do_get
      assigns(:training).should eq(training)
      assigns(:training).training_type_id.should == training_type.id
    end

    it "renders the form through edit js" do
      response.should render_template 'edit'
      response.should render_template '_form'
    end
  end

  describe "POST create though ajax" do
    def do_post
      xhr :post, :create, with_training_type_scope(:training => valid_attributes)
    end
    describe "with valid params" do
      it "creates a new Training" do
        expect {
          do_post
        }.to change(Training, :count).by(1)
      end

      it "assigns all trainings as @trainings" do
        do_post
        assigns(:trainings).should eq([Training.last])
      end

      it "renders index.js rendering training collection" do
        do_post
        response.should render_template 'index'
        response.should render_template '_training'
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
        assigns(:training).training_type_id.should == training_type.id
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
      end
    end
  end

  describe "PUT update through ajax" do
    before { create_training }
    def do_put(attributes = valid_attributes)
      xhr :put, :update, with_training_type_scope(:id => training.to_param, :training => attributes)
    end

    describe "with valid params" do
      it "updates the requested training" do
        # Assuming there are no other trainings in the database, this
        # specifies that the Training created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Training.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        do_put 'these' => 'params'
      end

      it "assigns the requested training as @training" do
        do_put
        assigns(:training).should eq(training)
        assigns(:training).training_type.should == training_type
      end

      it "redirects to the training through show.js.erb" do
        do_put
        response.should render_template 'show'
        response.should render_template '_training'
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
        assigns(:training).training_type.should == training_type
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { create_training }
    def do_delete
      xhr :delete, :destroy, with_training_type_scope(:id => training.to_param)
    end

    it "destroys the requested training" do
      expect {
        do_delete
      }.to change(Training, :count).by(-1)
    end

    it "redirects to the trainings list" do
      do_delete
      response.should render_template 'index'
      response.should render_template '_index'
    end
  end

end
