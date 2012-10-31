require 'spec_helper'

describe LocationsController do
  render_views
  prepare_scope :tenant

  let(:location) { FactoryGirl.create :location, :published => true }
  alias_method :create_location, :location

  describe "GET index" do
    it "assigns all published locations locations" do
      create_location
      get :index, {}
      assigns(:location_grouper).should eq(LocationGrouping.none([location]))
    end

    context "when no locations availables" do
      it "it renders no locations" do
        get :index
        assigns(:location_grouper).should eq(LocationGrouping.none([]))
      end
      it "renders a new organisiers link" do
        get :index 
        response.body.should have_selector("a[href='#{new_registration_organizer_url}']")
      end
    end
  end

  describe "Get map" do
    before do 
      create_location
      get :map, {}
    end

    it "assigns all published locations locations" do
      assigns(:locations).should eq([location])
    end
    it "renders a map" do
      response.should render_template(:map)
    end
  end

  describe "GET participant" do
    before { Location.stub(:availables_for_participants).and_return( [location] ) }

    it "assigns all published locations locations" do
      get :participant, {}
      assigns(:location_grouper).should eq(LocationGrouping.none([location]))
    end

    it "renders a new link to register without location" do
      get :participant 
      response.body.should have_selector("a[href='#{new_registration_participant_url}']")
    end

    context "when no locations availables" do
      before { Location.stub(:availables_for_participants).and_return( [] ) }
      it "it renders no locations" do
        get :participant
        assigns(:location_grouper).should eq(LocationGrouping.none([]))
      end
    end
  end

  describe "GET conversation_leaders" do
    before { Location.stub(:publisheds_for_conversation_leaders).and_return( [location] ) }

    it "assigns all published locations locations" do
      get :conversation_leader, {}
      assigns(:location_grouper).should eq(LocationGrouping.none([location]))
    end

    it "renders a new link to register without location" do
      get :conversation_leader 
      response.body.should have_selector("a[href='#{new_registration_conversation_leader_url}']")
    end

    context "when no locations availables" do
      before { Location.stub(:publisheds_for_conversation_leaders).and_return( [] ) }
      it "it renders no locations" do
        get :conversation_leader
        assigns(:location_grouper).should eq(LocationGrouping.none([]))
      end
    end
  end


  describe "GET show" do
    it "assigns the requested location as @location" do
      FactoryGirl.create :conversation, :location => location
      get :show, {:id => location.id}
      assigns(:location).should eq(location)
    end
    context "with conversations" do
      let!(:conversation) { FactoryGirl.create :conversation, location: location }
      it "shows no register link when marked as full" do
        location.update_attribute :marked_full, true
        get :show, { :id => location.id }
        response.body.should_not have_selector("a[href='#{new_registration_participant_path(:conversation_id => conversation.to_param)}']")
      end
    end
    it "says not found if location is not published" do
      location.update_attribute :published, false
      get :show, {:id => location.id}
      should respond_with(404)
    end
  end

end
