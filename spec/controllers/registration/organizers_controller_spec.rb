require 'spec_helper'
describe Registration::OrganizersController do
  render_views
  prepare_scope :tenant

  # This should return the minimal set of attributes required to create a valid
  # Organizer. As you add validations to Organizer, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    FactoryGirl.attributes_for(:organizer).stringify_keys
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Registration::OrganizersController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET new" do
    it "assigns a new person as @person" do
      get :new, {}, valid_session
      assigns(:organizer).should be_a_new(Organizer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Organizer" do
        expect {
          post :create, {:organizer => valid_attributes}, valid_session
        }.to change(Organizer, :count).by(1)
      end

      it "assigns a newly created person as @person" do
        post :create, {:organizer => valid_attributes}, valid_session
        assigns(:organizer).should be_a(Organizer)
        assigns(:organizer).should be_persisted
      end

      it "redirects to the created person" do
        post :create, {:organizer => valid_attributes}, valid_session
        response.should redirect_to confirm_registration_organizers_url
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved person as @person" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organizer.any_instance.stub(:save).and_return(false)
        post :create, {:organizer => {}}, valid_session
        assigns(:organizer).should be_a_new(Organizer)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organizer.any_instance.stub(:save).and_return(false)
        post :create, {:organizer => {}}, valid_session
        response.should render_template("new")
      end
    end
  end


end
