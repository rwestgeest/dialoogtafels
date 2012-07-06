require 'spec_helper'
describe Registration::OrganizersController do
  render_views
  prepare_scope :tenant

  def valid_attributes
    @valid_attributes ||= FactoryGirl.attributes_for(:organizer).stringify_keys
  end
  
  describe "GET new" do
    it "assigns a new person as @person" do
      get :new, {}
      assigns(:organizer).should be_a_new(Organizer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Organizer" do
        expect {
          post :create, {:organizer => valid_attributes}
        }.to change(Organizer, :count).by(1)
      end

      it "assigns a newly created person as @person" do
        post :create, {:organizer => valid_attributes}
        assigns(:organizer).should be_a(Organizer)
        assigns(:organizer).should be_persisted
      end

      it "signs in and redirects to a new location" do
        post :create, {:organizer => valid_attributes}
        flash.notice.should == I18n.t('.registration.organizers.welcome')
        current_account.should == Account.last
        response.should redirect_to new_organizer_location_url
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved person as @person" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organizer.any_instance.stub(:save).and_return(false)
        post :create, {:organizer => {}}
        assigns(:organizer).should be_a_new(Organizer)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organizer.any_instance.stub(:save).and_return(false)
        post :create, {:organizer => {}}
        response.should render_template("new")
      end
    end
    it_should_behave_like "a_captcha_handler", :organizer
  end


end
