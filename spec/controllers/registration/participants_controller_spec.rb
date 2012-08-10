require 'spec_helper'

describe Registration::ParticipantsController do
  render_views
  prepare_scope :tenant

  let!(:conversation) { FactoryGirl.create :conversation }

  def valid_attributes(overrides = {})
    @valid_attributes ||= FactoryGirl.attributes_for(:person).merge(overrides).stringify_keys
  end

  describe "GET new" do
    def do_get
      get :new, :conversation_id => conversation.to_param
    end

    it "assigns a new person as @person" do
      do_get
      assigns(:person).should be_a_new(Person)
      assigns(:conversation).should == conversation
    end

    it "puts the conversation_id in a hidden field" do
      do_get
      response.body.should have_selector "input[name='conversation_id'][type='hidden']"
    end

    it_should_behave_like "a_registration_form_with_profile_fields"

    it "renders not found when conversation_id not given" do
      get(:new) 
      should respond_with(404)
    end
  end

  describe "GET confirm" do
    login_as :participant
    let!(:conversation_leader) { FactoryGirl.create :conversation_leader, person: current_account.person }
    let(:conversations_where_i_participate) { current_account.person.conversations_participating_in_as_participant }
    let(:conversations_which_i_lead ) { current_account.person.conversations_participating_in }
    let(:conversations) { (conversations_where_i_participate + conversations_which_i_lead).uniq }
    let(:locations) { conversations.map {|c| c.location} }

    it "returns http success" do
      get 'confirm'
      response.should be_success
    end
    it "assigns the conversations" do
      get 'confirm'
      assigns(:conversations).sort.should == conversations.sort
    end
    it "renders the location" do
      get 'confirm' 
      locations.each do  |location |
        response.body.should include(location.name)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      def do_post
        post :create, {:person => valid_attributes, :conversation_id => conversation.to_param}
      end

      it "creates a new participant" do
        expect { do_post }.to change(Participant, :count).by(1)
      end

      it "creates a new person" do
        expect { do_post }.to change(Person, :count).by(1)
      end

      describe "when person with same email exists" do
        before { Person.create valid_attributes }
        it "does not create a new person" do 
          expect { do_post }.not_to change(Person, :count)
        end
        it "creates a new participant" do
          expect { do_post }.to change(Participant, :count).by(1)
        end
      end

      it "assigns a newly created person as @person" do
        do_post
        assigns(:participant).should be_a(Participant)
        assigns(:participant).should be_persisted
      end

      it "signs in and redirects to confirmation" do
        do_post
        flash.notice.should == I18n.t('.registration.participants.welcome')
        current_account.should == Account.last
        response.should redirect_to confirm_registration_participants_path
      end

      it "creates a notification for the registration" do
        Participant.any_instance.should_receive(:save_with_notification)
        do_post
      end
    end

    shared_examples_for "a_failing_participant_registration" do
      it "assigns a newly created but unsaved person as @person" do
        do_post
        assigns(:person).should be_a_new(Person)
        assigns(:conversation).should == conversation
      end

      it "re-renders the 'new' template" do
        do_post
        response.should render_template("new")
      end
    end

    describe "with invalid params" do
      it_should_behave_like "a_failing_participant_registration" do
        def do_post
          # Trigger the behavior that occurs when invalid params are submitted
          Participant.any_instance.stub(:save_with_notification).and_return(false)
          post :create, {:person => valid_attributes, :conversation_id => conversation.to_param}
        end
      end
    end

    describe "without email" do
      it_should_behave_like "a_failing_participant_registration" do
        def do_post 
          post :create, { :person => valid_attributes(email: nil), :conversation_id => conversation.to_param }
        end
      end
    end

    it "renders not found when conversation_id not given" do
      post :create, :person => valid_attributes
      should respond_with(404)
    end

    it_should_behave_like "a_captcha_handler", :person do 
      def do_post
        post :create, {:person => valid_attributes, :conversation_id => conversation.id}
      end
    end
  end

end
