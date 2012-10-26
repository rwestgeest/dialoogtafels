require 'spec_helper'
describe City::MailingMessagesController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  def valid_attributes
    FactoryGirl.attributes_for(:mailing_message)
  end

  let(:mailing_message) { FactoryGirl.create :mailing_message, :reference => active_project } 
  alias_method :create_mailing_message, :mailing_message

  describe "GET index" do
    it "assigns all mailing_messages as @mailing_messages" do
      create_mailing_message
      get :index, {}
      assigns(:mailing_messages).should eq([mailing_message])
    end
  end

  describe "GET show" do
    it "assigns the requested mailing_message as @mailing_message" do
      create_mailing_message
      get :show, {:id => mailing_message.to_param}
      assigns(:mailing_message).should eq(mailing_message)
    end
  end

  describe "POST create" do
    def do_post
      xhr :post, :create, {:mailing_message => valid_attributes, }
    end
    describe "with valid params" do
      it "creates a new MailingMessage" do
        expect { do_post }.to change(MailingMessage, :count).by(1)
      end

      it "assigns a newly created mailing_message as @mailing_message" do
        do_post 
        assigns(:mailing_message).should be_a(MailingMessage)
        assigns(:mailing_message).should be_persisted
      end

      it "redirects to the created mailing_message" do
        do_post
        response.should render_template 'create'
        response.should render_template '_mailing_message'
      end
    end

    describe "with for test" do
      def do_post
        xhr :post, :create, {:mailing_message => valid_attributes, :test_recipient => 'rob@gmail.com', :commit => 'test'}
      end
      it "creates a no MailingMessage" do
        expect { do_post }.not_to change(MailingMessage, :count)
      end

      it "assigns a newly created mailing_message as @mailing_message" do
        do_post 
        assigns(:mailing_message).should be_a(MailingMessage)
        assigns(:mailing_message).should_not be_persisted
      end

      it "assigns a coordinator as test_recepient_list" do
        do_post
        assigns(:test_recipient_list).should include(TenantAccount.first) 
      end

      it "redirects to the created mailing_message" do
        do_post
        response.should render_template 'new'
        response.should render_template '_new_mailing_message_form'
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        MailingMessage.any_instance.stub(:save).and_return(false)
        xhr :post, :create, {:mailing_message => {}}
      end
      it "assigns a newly created but unsaved mailing_message as @mailing_message" do
        assigns(:mailing_message).should be_a_new(MailingMessage)
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested mailing_message" do
      create_mailing_message
      expect {
        delete :destroy, {:id => mailing_message.to_param}
      }.to change(MailingMessage, :count).by(-1)
    end

    it "redirects to the mailing_messages list" do
      create_mailing_message
      delete :destroy, {:id => mailing_message.to_param}
      response.should redirect_to(city_mailing_messages_url)
    end
  end

end
