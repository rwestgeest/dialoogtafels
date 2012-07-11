require 'spec_helper'

describe City::CommentsController do
  render_views
  prepare_scope :tenant
  login_as :organizer

  let(:location) { FactoryGirl.create :location, :organizer => current_organizer }

  let(:location_comment) { FactoryGirl.create :location_comment, :reference => location }
  alias_method :create_location_comment, :location_comment

  def valid_attributes
    FactoryGirl.attributes_for(:location_comment)
  end

  def with_location_scope(request_parameters = {})
    {:location_id => location.to_param }.merge(request_parameters)
  end

  context "without supplying a location" do
    it { xhr(:get, :index); should respond_with(404) }
    it { xhr(:get, :show); should respond_with(404) }
    it { xhr(:post, :create, :location_comment => valid_attributes); should respond_with(404) }
  end

  describe "GET 'index'" do
    before do 
      create_location_comment
      get 'index', with_location_scope 
    end
    it "assigns the location and its comments" do
      other_comment = FactoryGirl.create :location_comment
      assigns(:location_comments).should  == [location_comment]
      assigns(:location).should == location
    end
    it "renders the index template" do
      response.should be_success
      response.should render_template 'index'
    end
    it "has a no parent_id hidden in the form" do
      response.body.should_not have_selector("form input[name='location_comment[parent_id]'][value='#{location_comment.id}'][type='hidden']")
    end
  end
  describe "GET 'show'" do
    before do 
      create_location_comment
      get 'show', with_location_scope(:id => location_comment.to_param)
    end
    it "assigns the location and its comments" do
      assigns(:location_comment).should  == location_comment
      assigns(:location).should == location
    end
    it "renders the show template" do
      response.should be_success
      response.should render_template 'show'
    end
    it "has a parent_id hidden in the form" do
      response.body.should have_selector("form input[name='location_comment[parent_id]'][value='#{location_comment.id}'][type='hidden']")
    end
  end
  describe "POST 'create'" do
    context "with valid parameters" do
      def do_post(extra_params = {})
        xhr :post, :create, with_location_scope(:location_comment => valid_attributes).merge(extra_params)
      end
      it "creates a comment for that location" do
        expect { do_post }.to change(LocationComment, :count).by(1)
      end
      it "assigns the newly created location_comment" do
        assigns(:location_comment).should == LocationComment.last
      end

      it "renders the create template" do
        do_post
        response.should render_template 'create'
        response.should render_template '_location_comment'
      end

      it "sets the addressees if supplied" do
        notifies = [ FactoryGirl.create(:person), FactoryGirl.create(:person) ]
        do_post :notify_people => notifies.map {|p| p.id.to_s}
        LocationComment.last.addressees.should == notifies
      end
    end
   
    context "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        LocationComment.any_instance.stub(:save).and_return(false)
        xhr :post, :create, with_location_scope(:location_comment => {})
      end
      it "assigns a newly created but unsaved location_comments as @location_comment" do
        assigns(:location_comment).should be_a_new(LocationComment)
        assigns(:location).should == location
      end

      it "re-renders the 'new' template" do
        response.should render_template('new')
        response.should render_template('_new')
      end
    end
  end
end
