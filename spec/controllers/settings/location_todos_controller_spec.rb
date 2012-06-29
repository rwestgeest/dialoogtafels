require 'spec_helper'

describe Settings::LocationTodosController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  def valid_attributes
    @valid_attribures ||= FactoryGirl.attributes_for(:location_todo).stringify_keys
  end

  let(:location_todo) { FactoryGirl.create :location_todo }
  alias_method :create_location_todo, :location_todo

  describe "GET edit" do
    it "assigns the requested location_todo as @location_todo" do
      location_todo = LocationTodo.create! valid_attributes
      xhr :get, :edit, :id => location_todo.id.to_s
      assigns(:location_todo).should eq(location_todo)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      def do_create
       xhr :post,  :create, :location_todo => valid_attributes
      end
      it "creates a new LocationTodo for current project" do
        expect { do_create }.to change(LocationTodo, :count).by(1)
        LocationTodo.last.project.should == active_project
      end

      it "assigns a newly created location_todo as @location_todo" do
        do_create
        assigns(:location_todo).should be_a(LocationTodo)
        assigns(:location_todo).should be_persisted
      end

      it "renders the list" do
        do_create
        response.should render_template('index')
      end
    end

    describe "with invalid params" do
      before do 
        # Trigger the behavior that occurs when invalid params are submitted
        LocationTodo.any_instance.stub(:save).and_return(false)
        xhr :post, :create, :location_todo => {}
      end
      it "assigns a newly created but unsaved location_todo as @location_todo" do
        assigns(:location_todo).should be_a_new(LocationTodo)
      end

      it "re-renders the 'new' template" do
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    before { create_location_todo }
    describe "with valid params" do
      def do_update
        xhr :put, :update, :id => location_todo.id, :location_todo => valid_attributes
      end
      it "updates the requested location_todo" do
        # Assuming there are no other location_todos in the database, this
        # specifies that the LocationTodo created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        LocationTodo.any_instance.should_receive(:update_attributes).with(valid_attributes)
        do_update
      end

      it "assigns the requested location_todo as @location_todo" do
        do_update
        assigns(:location_todo).should eq(location_todo)
      end

      it "redirects to the location_todo" do
        do_update
        response.should render_template('update')
      end
    end

    describe "with invalid params" do
      def do_update
        # Trigger the behavior that occurs when invalid params are submitted
        LocationTodo.any_instance.stub(:save).and_return(false)
        xhr :put, :update, :id => location_todo.id.to_s, :location_todo => {}
      end
      it "assigns the location_todo as @location_todo" do
        do_update
        assigns(:location_todo).should eq(location_todo)
      end

      it "re-renders the 'edit' template" do
        do_update
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { create_location_todo }
    def do_delete
      xhr :delete, :destroy, :id => location_todo.id.to_s
    end
    it "destroys the requested location_todo" do
      expect { do_delete }.to change(LocationTodo, :count).by(-1)
    end

    it "redirects to the location_todos list" do
      do_delete
      response.should render_template('index')
    end
  end

end
