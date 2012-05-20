require 'spec_helper'


describe ConversationsController do
  render_views
  prepare_scope :tenant
  login_as :organizer

  let(:location) { FactoryGirl.create :location, :organizer => current_organizer }

  def create_conversation
    FactoryGirl.create :conversation, :location => location
  end

  def valid_attributes
    FactoryGirl.attributes_for :conversation, :location_id => location.to_param
  end
  

  describe "GET show" do
    let!(:conversation) { create_conversation }
    it "assigns the requested conversation as @conversation" do
      xhr :get, :show, {:id => conversation.to_param}
      assigns(:conversation).should eq(conversation)
    end
    it "should render the show partial through show.js" do
      xhr :get, :show, {:id => conversation.to_param}
      response.should render_template('conversations/show')
      response.should render_template('conversations/_show')
    end
  end

  describe "GET new" do
    context "for location" do
      before { xhr :get, :new, :location => location.to_param }

      it "assigns a new conversation as @conversation" do
        assigns(:conversation).should be_a_new(Conversation)
        assigns(:conversation).location.should == location
      end
      it "should render the show partial through new.js" do
        response.should render_template('conversations/new')
        response.should render_template('conversations/_new')
      end
    end
    context "without supplying a location" do
      before { xhr :get, :new }
      it { should respond_with(404) }
    end
  end

  describe "GET edit" do
    let!(:conversation) { create_conversation }
    it "assigns the requested conversation as @conversation" do
      xhr :get, :edit, {:id => conversation.to_param}
      assigns(:conversation).should eq(conversation)
    end
    it "should render the edit partial through edit.js" do
      xhr :get, :edit, {:id => conversation.to_param}
      response.should render_template('conversations/edit')
      response.should render_template('conversations/_edit')
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Conversation" do
        expect {
          xhr :post, :create, {:conversation => valid_attributes}
        }.to change(Conversation, :count).by(1)
      end

      it "assigns a newly created conversation as @conversation" do
        xhr :post, :create, {:conversation => valid_attributes}
        assigns(:conversation).should be_a(Conversation)
        assigns(:conversation).should be_persisted
      end

      it "renders the list" do
        xhr :post, :create, {:conversation => valid_attributes}
        response.should render_template('conversations/index')
        response.should render_template('conversations/_index')
      end

    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved conversation as @conversation" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        xhr :post, :create, {:conversation => {}}
        assigns(:conversation).should be_a_new(Conversation)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        xhr :post, :create, {:conversation => {}}
        response.should render_template('conversations/new')
        response.should render_template('conversations/_new')
      end
    end
  end

  describe "PUT update" do
    let!(:conversation) { create_conversation }

    describe "with valid params" do
      it "updates the requested conversation" do
        conversation = Conversation.create! valid_attributes
        # Assuming there are no other conversations in the database, this
        # specifies that the Conversation created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Conversation.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        xhr :put, :update, {:id => conversation.to_param, :conversation => {'these' => 'params'}}
      end

      it "assigns the requested conversation as @conversation" do
        conversation = Conversation.create! valid_attributes
        xhr :put, :update, {:id => conversation.to_param, :conversation => valid_attributes}
        assigns(:conversation).should eq(conversation)
      end

      it "renders the show template" do
        conversation = Conversation.create! valid_attributes
        xhr :put, :update, {:id => conversation.to_param, :conversation => valid_attributes}
        response.should render_template('conversations/show')
        response.should render_template('conversations/_show')
      end
    end

    describe "with invalid params" do
      it "assigns the conversation as @conversation" do
        conversation = Conversation.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        xhr :put, :update, {:id => conversation.to_param, :conversation => {}}
        assigns(:conversation).should eq(conversation)
      end

      it "re-renders the 'edit' template" do
        conversation = Conversation.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        xhr :put, :update, {:id => conversation.to_param, :conversation => {}}
        response.should render_template('conversations/edit')
        response.should render_template('conversations/_edit')
      end
    end
  end

  describe "DELETE destroy" do
    let!(:conversation) { create_conversation }
    it "destroys the requested conversation" do
      expect {
        xhr :delete, :destroy, {:id => conversation.to_param}
      }.to change(Conversation, :count).by(-1)
    end

    it "renders the list" do
      xhr :delete, :destroy, {:id => conversation.to_param}
      response.should render_template('conversations/index')
      response.should render_template('conversations/_index')
    end
  end

end
