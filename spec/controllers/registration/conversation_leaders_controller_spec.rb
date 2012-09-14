require 'spec_helper'

describe Registration::ConversationLeadersController do
  render_views
  prepare_scope :tenant

  let!(:conversation) { FactoryGirl.create :conversation }

  def valid_attributes(overrides = {})
    @valid_attributes ||= FactoryGirl.attributes_for(:person).merge(overrides).stringify_keys
  end

  shared_examples_for "a_conversation_leader_registration_form" do

    it "assigns a new person as @person" do
      do_get
      assigns(:person).should be_a_new(Person)
    end

    it "renders a form" do
      do_get
      response.body.should have_selector "form[action='#{registration_conversation_leaders_path}'][method='post']"
    end

    it_should_behave_like "a_registration_form_with_profile_fields"

  end

  describe "GET new" do
    describe "with conversation parameter" do
      def do_get
        get :new, :conversation_id => conversation.to_param
      end

      it_should_behave_like "a_conversation_leader_registration_form"

      it "assigns the conversation " do
        do_get
        assigns(:conversation).should == conversation
      end

      it "puts the conversation_id in a hidden field" do
        do_get
        response.body.should have_selector "input[name='conversation_id'][type='hidden'][value='#{conversation.to_param}']"
      end
    end

    describe "without conversation parameter" do
      def do_get
        get(:new) 
      end

      it_should_behave_like "a_conversation_leader_registration_form"

      it "renders the new ambition template" do
        do_get
        response.should render_template(:new_ambition)
      end

      it "has a link to all the locations for a conversation leader" do
        do_get 
        response.should have_link_to(conversation_leader_locations_path)
      end
    end
  end

  describe "POST create" do
    shared_examples_for "a_conversation_leader_registrar" do
      it "creates a new conversation_leader_ambition" do
        expect { do_post }.to change(ConversationLeaderAmbition, :count).by(1)
      end

      it "signs in an redirects to contributors first_landing_page" do
        do_post
        flash.notice.should == I18n.t('.registration.conversation_leaders.welcome')
        current_account.should == Account.last
        response.should redirect_to confirm_registration_conversation_leaders_path
      end

      it "creates a notification for the registration" do
        Messenger.should_receive(:new_conversation_leader_ambition).with an_instance_of(Person)
        do_post
      end

      describe "when training registrations provided" do
        let!(:training) { FactoryGirl.create :training }
        it "creates a training registration" do
          expect { 
            do_post( training_registrations: { training.training_type_id => training.to_param })  
          }.to change(TrainingRegistration, :count).by(1)
        end
      end

      context "when conversation provided" do
        def do_post(additional_attributes = {})
          post :create, {:person => valid_attributes, :conversation_id => conversation.to_param}.merge(additional_attributes)
        end

        it "creates a new conversation_leader" do
          expect { do_post }.to change(ConversationLeader, :count).by(1)
        end

        it "the new conversation leader is associated with the conversation" do
          do_post
          conversation.conversation_leaders.should include ConversationLeader.last
        end

        it "creates a notification for the registration" do
          Messenger.should_receive(:new_conversation_leader).with an_instance_of(Person),  conversation
          do_post
        end
      end

    end

    describe "with valid params" do
      def do_post(additional_attributes = {})
        post :create, {:person => valid_attributes}.merge(additional_attributes)
      end

      it_should_behave_like "a_conversation_leader_registrar"

      it "creates a new person" do
        expect { do_post }.to change(Person, :count).by(1)
      end

      it "assigns a newly created person as @person" do
        do_post
        assigns(:person).should be_a(Person)
        assigns(:person).should be_persisted
      end

      describe "when person with same email exists" do
        before { Person.create valid_attributes }

        it "does not create a new person" do 
          expect { do_post }.not_to change(Person, :count)
        end

        it_should_behave_like "a_conversation_leader_registrar"
      end
    end

    shared_examples_for "a_failing_conversation_leader_registration" do
      it "assigns a newly created but unsaved person as @person" do
        do_post
        assigns(:person).should be_a(Person)
        assigns(:conversation).should == conversation
      end

      it "does not create a new conversation_leader" do
        expect { do_post }.not_to change(ConversationLeader, :count)
      end

      it "does not create a new conversation_leader_ambition" do
        expect { do_post }.not_to change(ConversationLeaderAmbition, :count)
      end

      it "re-renders the 'new' template" do
        do_post
        response.should render_template("new")
      end

      it "renders a form with the post method" do
        do_post
        response.body.should_not have_selector "form input[name='_method'][value='put']"
      end

      # it "preserves the training selection" do
      #   training = FactoryGirl.create(:training)
      #   do_post(:training_registrations => {training.training_type_id => training.to_param})
      #   assigns(:person).should be_registered_for_training(training.to_param)
      # end
    end

    describe "with invalid params" do
      it_should_behave_like "a_failing_conversation_leader_registration" do
        def do_post(additional_parameters = {})
          # Trigger the behavior that occurs when invalid params are submitted
          Person.any_instance.stub(:save).and_return(false)
          post :create, {:person => valid_attributes, :conversation_id => conversation.to_param}
        end
      end
    end

    describe "without email" do
      it_should_behave_like "a_failing_conversation_leader_registration" do
        def do_post(additional_parameters = {})
          post :create, { :person => valid_attributes(email: nil), :conversation_id => conversation.to_param }.merge(additional_parameters)
        end
      end
    end

    describe "with existing email without name" do
      it_should_behave_like "a_failing_conversation_leader_registration" do
        let(:person) { FactoryGirl.create :person } 
        def do_post 
          post :create, { :person => valid_attributes(email: person.email, name: nil), :conversation_id => conversation.to_param }
        end
      end
    end

    it_should_behave_like "a_captcha_handler", :person do
      def do_post
        post :create, { :person => valid_attributes, :conversation_id => conversation.to_param }
      end
    end
  end

  describe "GET confirm" do
  
    let(:conversations_where_i_participate) { current_account.person.conversations_participating_in_as_participant }
    let(:conversations_which_i_lead ) { current_account.person.conversations_participating_in }
    let(:conversations) { (conversations_where_i_participate + conversations_which_i_lead).uniq }
    let(:locations) { conversations.map {|c| c.location} }

    context "when i am a conversation leader with location" do
      login_as :conversation_leader

      before do
        FactoryGirl.create :participant, person: current_account.person
        FactoryGirl.create :conversation_leader, person: current_account.person 
      end

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

    context "when i am a conversation leader without location" do
      login_as :conversation_leader_ambition

      it "returns http success" do
        get 'confirm'
        response.should be_success
      end
    end


  end


end
