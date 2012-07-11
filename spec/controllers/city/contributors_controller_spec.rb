require 'spec_helper'

describe City::ContributorsController, :focus => true do
  render_views 
  prepare_scope :tenant
  login_as :coordinator

  attr_reader :location
  before(:all) { @location = FactoryGirl.create :location }

  let(:todo) { FactoryGirl.create :location_todo, :project => location.project }

  def with_location_scope(request_parameters = {})
    {:location_id => location.to_param }.merge(request_parameters)
  end

  context "without supplying a location" do
    it { xhr(:get, :index); should respond_with(404) }
  end

  describe "GET 'index'" do
    before { xhr :get, 'index', with_location_scope }
    it "renders the index" do
      response.should be_success
      response.should render_template 'index'
      response.should render_template '_index'
    end
    context "when location contains contributors" do
      let!(:conversation) { FactoryGirl.create :conversation, location: location }
      let!(:conversation_leader) { FactoryGirl.create :conversation_leader, conversation: conversation } 
      let!(:participant) { FactoryGirl.create :participant, conversation: conversation } 

      it "assigns the location, conversation leaders and participants" do
        assigns(:location).should == location
        assigns(:conversation_leaders).should == [conversation_leader] 
        assigns(:participants).should == [participant] 
      end
    end
  end

end
