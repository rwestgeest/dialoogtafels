require 'spec_helper'


describe City::PublicationsController do
  render_views 
  prepare_scope :tenant
  login_as :organizer

  def valid_attributes
    @valid_attributes ||= FactoryGirl.attributes_for(:location).stringify_keys
  end

  def with_location_scope(request_parameters = {})
    {:location_id => location.to_param }.merge(request_parameters)
  end

  let(:location) { FactoryGirl.create :location } 
  alias_method :create_location, :location

  context "without location" do
    it {get(:new); should respond_with(404) }
    it {get(:show); should respond_with(404) }
    it {get(:edit); should respond_with(404) }
    it {post(:create); should respond_with(404) }
    it {put(:update); should respond_with(404) }
  end
  context "with location" do
    describe "GET show" do
      it "assigns the requested location as @location" do
        get :show, with_location_scope
        assigns(:location).should eq(location)
      end
    end
    describe "GET new" do
      it "assigns a new location as @location" do
        get :new, with_location_scope
        assigns(:location).should eq(location)
        response.body.should have_selector("form[action='#{city_location_publication_path(:location_id => location.to_param)}']")
      end
    end

    describe "GET edit" do
      it "assigns the requested location as @location" do
        get :edit, with_location_scope
        assigns(:location).should eq(location)
        response.body.should have_selector("form[action='#{city_location_publication_path(:location_id => location.to_param)}']")
      end
    end

    describe "POST create" do
      def do_post
        post :create, with_location_scope(:location => valid_attributes)
      end
      describe "with valid params" do
        it "does not create a new Location - merely updates the publication details" do
          create_location
          # Assuming there are no other locations_locations in the database, this
          # specifies that the Location created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Location.any_instance.should_receive(:update_attributes).with(valid_attributes)
          do_post
        end

        it "assigns a newly created location as @location" do
          do_post
          assigns(:location).should be_a(Location)
          assigns(:location).should be_persisted
        end

        it "redirects to the created location" do
          do_post
          response.should redirect_to(city_location_publication_url(:location_id => location))
        end
      end

      describe "with invalid params" do
        before do
          # Trigger the behavior that occurs when invalid params are submitted
          Location.any_instance.stub(:save).and_return(false)
          do_post
        end

        it "assigns a the location to @location" do
          assigns(:location).should == location
        end

        it "re-renders the 'new' template" do
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      def do_put
        put :update, with_location_scope( :location => valid_attributes )
      end
      describe "with valid params" do
        it "updates the requested location" do
          # Assuming there are no other locations_locations in the database, this
          # specifies that the Location created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Location.any_instance.should_receive(:update_attributes).with(valid_attributes)
          do_put
        end

        it "assigns the requested location as @location" do
          do_put
          assigns(:location).should eq(location)
        end

        it "redirects to the location" do
          do_put
          response.should redirect_to(city_location_publication_url(:location_id => location))
        end
      end

      describe "with invalid params" do
        before do
          # Trigger the behavior that occurs when invalid params are submitted
          Location.any_instance.stub(:save).and_return(false)
          do_put
        end
        it "assigns the location as @location" do
          assigns(:location).should eq(location)
        end

        it "re-renders the 'edit' template" do
          response.should render_template("edit")
        end
      end
    end
  end
end
