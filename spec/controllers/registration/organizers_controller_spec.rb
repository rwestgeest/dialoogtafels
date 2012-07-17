require 'spec_helper'
describe Registration::OrganizersController do
  render_views
  prepare_scope :tenant

  def valid_attributes( attr_overrides = {} )
    @valid_attributes ||= FactoryGirl.attributes_for(:organizer, attr_overrides).stringify_keys
  end
  
  describe "GET new" do
    it "assigns a new person as @person" do
      get :new, {}
      assigns(:organizer).should be_a_new(Organizer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Organizer" do
        expect {
          post :create, {:organizer => valid_attributes}
        }.to change(Organizer, :count).by(1)
      end

      it "assigns a newly created organizer as @organizer" do
        post :create, {:organizer => valid_attributes}
        assigns(:organizer).should be_a(Organizer)
        assigns(:organizer).should be_persisted
      end

      it "signs in and redirects to the organizers first_landing_page" do
        Organizer.any_instance.stub(:first_landing_page).and_return "/first_landing"
        post :create, {:organizer => valid_attributes}
        flash.notice.should == I18n.t('.registration.organizers.welcome')
        current_account.should == Account.last
        response.should redirect_to '/first_landing'
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved person as @person" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organizer.any_instance.stub(:save).and_return(false)
        post :create, {:organizer => {}}
        assigns(:organizer).should be_a_new(Organizer)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organizer.any_instance.stub(:save).and_return(false)
        post :create, {:organizer => {}}
        response.should render_template("new")
      end
    end

    describe "when organizer exists" do
      let!(:organizer) { FactoryGirl.create :organizer }
      
      def do_post
        post :create, :organizer => valid_attributes(:email => organizer.email)
      end

      it "does not create a new one" do
        expect { do_post }.not_to change(Organizer, :count)
      end

      it "redirects to login page" do
        do_post 
        response.should redirect_to( new_account_session_path(:email => organizer.email) )
      end
    end

    it_should_behave_like "a_captcha_handler", :organizer
  end


end
