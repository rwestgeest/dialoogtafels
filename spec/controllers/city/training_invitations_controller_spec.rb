require 'spec_helper'

describe City::TrainingInvitationsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  let(:training) { FactoryGirl.create :training }

  let(:training_invitation) { FactoryGirl.create :training_invitation, :reference => training}
  alias_method :create_training_invitation, :training_invitation

  def valid_attributes
    FactoryGirl.attributes_for(:training_invitation)
  end

  def with_training_scope(request_parameters = {})
    {:training_id => training.to_param }.merge(request_parameters)
  end

  context "without supplying a training" do
    it { xhr(:get, :index); should respond_with(404) }
    it { xhr(:post, :create, :training_comment => valid_attributes); should respond_with(404) }
  end

  describe "GET 'index'" do
    before do 
      create_training_invitation
      get 'index', with_training_scope 
    end
    it "assigns the training and its comments" do
      other_comment = FactoryGirl.create :training_invitation
      assigns(:training_invitations).should  == [training_invitation]
      assigns(:training).should == training
    end
    it "renders the index template" do
      response.should be_success
      response.should render_template 'index'
    end
    it "has a no parent_id hidden in the form" do
      response.body.should_not have_selector("form input[name='training_invitation[parent_id]'][value='#{training_invitation.id}'][type='hidden']")
    end
  end

  describe "POST 'create'" do
    context "with valid parameters" do
      def do_post(extra_params = {})
        xhr :post, :create, with_training_scope(:training_invitation => valid_attributes).merge(extra_params)
      end
      it "creates a comment for that training" do
        expect { do_post }.to change(TrainingInvitation, :count).by(1)
      end
      it "assigns the newly created training_invitation" do
        assigns(:training_invitation).should == TrainingInvitation.last
      end

      it "renders the create template" do
        do_post
        response.should render_template 'create'
        response.should render_template '_training_invitation'
      end

      it "sets the addressees if supplied" do
        notifies = [ FactoryGirl.create(:person), FactoryGirl.create(:person) ]
        do_post :notify_people => notifies.map {|p| p.id.to_s}
        TrainingInvitation.last.addressees.should == notifies
      end
    end
   
    context "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        TrainingInvitation.any_instance.stub(:save).and_return(false)
        xhr :post, :create, with_training_scope(:training_invitation => {})
      end
      it "assigns a newly created but unsaved training_invitations as @training_invitation" do
        assigns(:training_invitation).should be_a_new(TrainingInvitation)
        assigns(:training).should == training
      end

      it "re-renders the 'new' template" do
        response.should render_template('new')
        response.should render_template('_new')
      end
    end
  end

end
