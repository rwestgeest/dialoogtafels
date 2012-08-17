require 'spec_helper'

describe City::TrainingTypesController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  def valid_attributes
    FactoryGirl.attributes_for :training_type
  end

  let(:training_type) { FactoryGirl.create :training_type }
  alias_method :create_training_type, :training_type
  
  describe "GET index" do
    def do_get
      get :index, {}
    end
    it "assigns all training_types as @training_types" do
      training_type = TrainingType.create! valid_attributes
      do_get
      assigns(:training_types).should eq([training_type])
    end
  end

  describe "GET show" do
    it "assigns the requested training_type as @training_type" do
      training_type = TrainingType.create! valid_attributes
      get :show, {:id => training_type.to_param}
      assigns(:training_type).should eq(training_type)
    end
  end

  describe "GET new" do
    it "assigns a new training_type as @training_type" do
      get :new, {}
      assigns(:training_type).should be_a_new(TrainingType)
    end
  end

  describe "GET edit" do
    it "assigns the requested training_type as @training_type" do
      training_type = TrainingType.create! valid_attributes
      get :edit, {:id => training_type.to_param}
      assigns(:training_type).should eq(training_type)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TrainingType" do
        expect {
          post :create, {:training_type => valid_attributes}
        }.to change(TrainingType, :count).by(1)
      end

      it "assigns a newly created training_type as @training_type" do
        post :create, {:training_type => valid_attributes}
        assigns(:training_type).should be_a(TrainingType)
        assigns(:training_type).should be_persisted
      end

      it "redirects to the trainingtype" do
        post :create, {:training_type => valid_attributes}
        response.should redirect_to(city_training_type_path(TrainingType.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved training_type as @training_type" do
        # Trigger the behavior that occurs when invalid params are submitted
        TrainingType.any_instance.stub(:save).and_return(false)
        post :create, {:training_type => {}}
        assigns(:training_type).should be_a_new(TrainingType)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TrainingType.any_instance.stub(:save).and_return(false)
        post :create, {:training_type => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested training_type" do
        training_type = TrainingType.create! valid_attributes
        # Assuming there are no other training_types in the database, this
        # specifies that the TrainingType created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TrainingType.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => training_type.to_param, :training_type => {'these' => 'params'}}
      end

      it "assigns the requested training_type as @training_type" do
        training_type = TrainingType.create! valid_attributes
        put :update, {:id => training_type.to_param, :training_type => valid_attributes}
        assigns(:training_type).should eq(training_type)
      end

      it "redirects to the training_type" do
        training_type = TrainingType.create! valid_attributes
        put :update, {:id => training_type.to_param, :training_type => valid_attributes}
        response.should redirect_to(city_training_type_path(training_type))
      end
    end

    describe "with invalid params" do
      it "assigns the training_type as @training_type" do
        training_type = TrainingType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TrainingType.any_instance.stub(:save).and_return(false)
        put :update, {:id => training_type.to_param, :training_type => {}}
        assigns(:training_type).should eq(training_type)
      end

      it "re-renders the 'edit' template" do
        training_type = TrainingType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TrainingType.any_instance.stub(:save).and_return(false)
        put :update, {:id => training_type.to_param, :training_type => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested training_type" do
      training_type = TrainingType.create! valid_attributes
      expect {
        delete :destroy, {:id => training_type.to_param}
      }.to change(TrainingType, :count).by(-1)
    end

    it "redirects to the training_types list" do
      training_type = TrainingType.create! valid_attributes
      delete :destroy, {:id => training_type.to_param}
      response.should redirect_to(city_training_types_path)
    end
  end

end
