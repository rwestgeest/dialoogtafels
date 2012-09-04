require 'spec_helper'
describe Registration::OrganizersController do
  render_views
  prepare_scope :tenant

  def valid_attributes( attr_overrides = {} )
    @valid_attributes ||= FactoryGirl.attributes_for(:person, attr_overrides).stringify_keys
  end
  
  describe "GET new" do
    def do_get
      get :new, {}
    end

    it "assigns a new person as @person" do
      do_get
      assigns(:person).should be_a_new(Person)
    end

    it "renders a form" do
      do_get
      response.body.should have_selector "form[action='#{registration_organizers_path}'][method='post']"
    end

    it_should_behave_like "a_registration_form_with_profile_fields"
  end

  describe "POST create" do
    describe "with valid params" do
      def do_post
        post :create, {:person => valid_attributes}
      end

      it "creates a new Organizer" do
        expect { do_post }.to change(Organizer, :count).by(1)
      end

      it "creates a new Person" do
        expect { do_post }.to change(Person, :count).by(1)
      end

      it "assigns a newly created organizer as @organizer" do
        do_post
        assigns(:organizer).should be_a(Organizer)
        assigns(:organizer).should be_persisted
      end

      it "signs in and redirects to the organizers first_landing_page" do
        Organizer.any_instance.stub(:first_landing_page).and_return "/first_landing"
        do_post
        flash.notice.should == I18n.t('.registration.organizers.welcome')
        current_account.should == Account.last
        response.should redirect_to '/first_landing'
      end

      it "sends a new_organizer event" do
        Messenger.should_receive(:new_organizer).with an_instance_of(Organizer)
        do_post
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Person.any_instance.stub(:save).and_return(false)
      end
      def do_post
        post :create, {:person => {}}
      end
      it "assigns a newly created but unsaved person as @person" do
        do_post
        assigns(:person).should be_a_new(Person)
      end

      it "re-renders the 'new' template" do
        do_post
        response.should render_template("new")
      end
      it "does not send a new_organizer event" do
        Messenger.should_not_receive(:new_organizer)
        do_post
      end
    end

    describe "when organizer exists" do
      let!(:organizer) { FactoryGirl.create :organizer }
      
      def do_post
        post :create, :person => valid_attributes(:email => organizer.email)
      end

      it "does not create a new one" do
        expect { do_post }.not_to change(Organizer, :count)
      end

      it "redirects to login page" do
        do_post 
        response.should redirect_to( new_account_session_path(:email => organizer.email) )
      end

      it "does not send a new_organizer event" do
        Messenger.should_not_receive(:new_organizer)
        do_post
      end
    end

    it_should_behave_like "a_captcha_handler", :person do
      def do_post
        post :create, :person => valid_attributes
      end
    end
  end


end
