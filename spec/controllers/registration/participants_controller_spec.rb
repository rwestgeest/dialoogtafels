require 'spec_helper'

describe Registration::ParticipantsController do
  render_views
  prepare_scope :tenant

  let!(:conversation) { FactoryGirl.create :conversation }

  def valid_attributes(overrides = {})
    @valid_attributes ||= FactoryGirl.attributes_for(:person).merge(overrides).stringify_keys
  end

  shared_examples_for "a_participant_registration_form" do

    it "assigns a new person as @person" do
      do_get
      assigns(:person).should be_a_new(Person)
    end

    it "renders a form" do
      do_get
      response.body.should have_selector "form[action='#{registration_participants_path}'][method='post']"
    end

    it_should_behave_like "a_registration_form_with_profile_fields"
  end

  describe "GET new" do
    describe "with conversation parameter" do
      def do_get
        get :new, :conversation_id => conversation.to_param
      end

      it_should_behave_like "a_participant_registration_form" 

      it "assigns a new conversation as @conversation" do
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

      it_should_behave_like "a_participant_registration_form"

      it "renders the new ambition template" do
        do_get
        response.should render_template(:new_ambition)
      end
    end
  end

  describe "POST create" do
    shared_examples_for "a_participant_registrar" do
      it "creates a new participant_ambition" do
        expect { do_post }.to change(ParticipantAmbition, :count).by(1)
      end

      it "signs in and redirects to confirmation" do
        do_post
        flash.notice.should == I18n.t('.registration.participants.welcome')
        current_account.should == Account.last
        response.should redirect_to confirm_registration_participants_path
      end

      it "creates a notification for the registration" do
        Messenger.should_receive(:new_participant_ambition).with an_instance_of(Person)
        do_post
      end

      context "when conversation provided" do
        def do_post(additional_attributes = {})
          post :create, {:person => valid_attributes, :conversation_id => conversation.to_param}.merge(additional_attributes)
        end

        it "creates a new participant" do
          expect { do_post }.to change(Participant, :count).by(1)
        end

        it "the new conversation leader is associated with the conversation" do
          do_post
          conversation.participants.should include Participant.last
        end

        it "creates a notification for the registration" do
          Messenger.should_receive(:new_participant).with an_instance_of(Person),  conversation
          do_post
        end
      end

    end

    describe "with valid params" do
      def do_post
        post :create, {:person => valid_attributes}
      end

      it_should_behave_like "a_participant_registrar"

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

        it_should_behave_like "a_participant_registrar" 
      end

    end

    shared_examples_for "a_failing_participant_registration" do
      it "assigns a newly created but unsaved person as @person" do
        do_post
        assigns(:person).should be_a(Person)
        assigns(:conversation).should == conversation
      end

      it "re-renders the 'new' template" do
        do_post
        response.should render_template("new")
      end

      it "renders a form with the post method" do
        do_post
        response.body.should_not have_selector "form input[name='_method'][value='put']"
      end

      it "does not create a new participant" do
        expect { do_post }.not_to change(Participant, :count)
      end

      it "does not create a new participant_ambition" do
        expect { do_post }.not_to change(ParticipantAmbition, :count)
      end

      it "does not send any email" do
        Messenger.should_not_receive(:new_participant)
      end

    end

    describe "with invalid params" do
      it_should_behave_like "a_failing_participant_registration" do
        def do_post
          # Trigger the behavior that occurs when invalid params are submitted
          Person.any_instance.stub(:save).and_return(false)
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

    describe "with existing email without name" do
      it_should_behave_like "a_failing_participant_registration" do
        let(:person) { FactoryGirl.create :person } 
        def do_post 
          post :create, { :person => valid_attributes(email: person.email, name: nil), :conversation_id => conversation.to_param }
        end
      end
    end

    it_should_behave_like "a_captcha_handler", :person do 
      def do_post
        post :create, {:person => valid_attributes, :conversation_id => conversation.id}
      end
    end
  end

  describe "GET confirm" do

    let(:conversations_where_i_participate) { current_account.person.conversations_participating_in_as_participant }
    let(:conversations_which_i_lead ) { current_account.person.conversations_participating_in }
    let(:conversations) { (conversations_where_i_participate + conversations_which_i_lead).uniq }
    let(:locations) { conversations.map {|c| c.location} }

    context "when i am a participant with location" do
      login_as :participant
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

    context "when i am a participant without location" do
      login_as :participant_ambition

      it "returns http success" do
        get 'confirm'
        response.should be_success
      end
    end

  end

end
