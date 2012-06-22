require 'spec_helper'

describe City::CommentsController do
  render_views
  prepare_scope :tenant
  login_as :organizer

  let(:location) { FactoryGirl.create :location, :organizer => current_organizer }

  let(:location_comment) { FactoryGirl.create :location_comment, :location => location }
  alias_method :create_location_comment, :location_comment

  def valid_attributes
    FactoryGirl.attributes_for(:location_comment).merge :location_id => location.to_param
  end

  def with_location_scope(request_parameters = {})
    {:location_id => location.to_param }.merge(request_parameters)
  end
  context "without supplying a location" do
    it { xhr(:get, :new); should respond_with(404) }
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
  end
  describe "POST 'create'" do
    context "with valid parameters" do
      def do_post
        xhr :post, :create, with_location_scope(:location_comment => valid_attributes)
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
