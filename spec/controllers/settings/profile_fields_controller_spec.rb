require 'spec_helper'

describe Settings::ProfileFieldsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  def valid_attributes
    @valid_attributes ||= FactoryGirl.attributes_for :profile_field
  end

  let(:profile_field) { FactoryGirl.create :profile_string_field }
  alias_method :create_profile_field, :profile_field

  describe "GET index" do
    it "assigns all profile_fields as @profile_fields" do
      create_profile_field
      get :index, {}
      assigns(:profile_fields).should eq([profile_field])
    end
  end

  describe "GET new" do
    before { xhr :get, :new }
    it "assigns a new profile_field as @profile_field" do
      assigns(:profile_field).should be_a_new(ProfileStringField)
    end
    it "renders the 'new' template" do
      response.should render_template("new")
      response.should render_template("_new")
    end
  end

  describe "GET edit" do
    before do 
      create_profile_field
      xhr :get, :edit, {:id => profile_field.to_param}
    end

    it "assigns the requested profile_field as @profile_field" do
      assigns(:profile_field).should eq(profile_field)
    end
    it "renders the 'edit' template" do
      response.should render_template("edit")
      response.should render_template("_edit")
    end
  end

  describe "POST create" do
    def do_post
      xhr :post, :create, {:profile_field => valid_attributes}
    end
    describe "with valid params" do
      it "creates a new ProfileField" do
        expect { do_post }.to change(ProfileField, :count).by(1)
      end

      it "assigns a newly created profile_field as @profile_field" do
        do_post
        assigns(:profile_field).should be_a(ProfileField)
        assigns(:profile_field).should be_persisted
      end

      it "shows the new list" do
        do_post
        response.should render_template("index")
        response.should render_template("_index")
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        ProfileField.any_instance.stub(:save).and_return(false)
        do_post
      end
      it "assigns a newly created but unsaved profile_field as @profile_field" do
        assigns(:profile_field).should be_a_new(ProfileField)
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
        response.should render_template("_new")
      end
    end
  end

  describe "PUT update" do
    before { create_profile_field }
    def do_put
      xhr :put, :update, {:id => profile_field.to_param, :profile_field => valid_attributes}
    end
    describe "with valid params" do
      it "updates the requested profile_field" do
        # Assuming there are no other profile_fields in the database, this
        # specifies that the ProfileField created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ProfileStringField.any_instance.should_receive(:update_attributes).with(valid_attributes.stringify_keys)
        do_put
      end

      it "assigns the requested profile_field as @profile_field" do 
        do_put
        assigns(:profile_field).should eq(profile_field)
      end

      it "redirects to the profile_field" do
        do_put
        response.should render_template("show")
        response.should render_template("_profile_field")
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        ProfileStringField.any_instance.stub(:save).and_return(false)
        do_put
      end

      it "assigns the profile_field as @profile_field" do
        assigns(:profile_field).should eq(profile_field)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
        response.should render_template("_edit")
      end
    end
  end

  describe "DELETE destroy" do
    before { create_profile_field }
    it "destroys the requested profile_field" do
      expect {
        xhr :delete, :destroy, {:id => profile_field.to_param}
      }.to change(ProfileField, :count).by(-1)
    end

    it "redirects to the profile_fields list" do
      xhr :delete, :destroy, {:id => profile_field.to_param}
      response.should render_template('index')
      response.should render_template('_index')
    end
  end

end
