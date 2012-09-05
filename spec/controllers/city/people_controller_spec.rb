require 'spec_helper'

describe City::PeopleController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  let(:person) { FactoryGirl.create :person }
  alias_method :create_person, :person
  let(:profile_field) { FactoryGirl.create :profile_string_field, :field_name => 'age', :label => 'Age'  }
  alias_method :create_profile_field, :profile_field
  
  def valid_parameters
    FactoryGirl.attributes_for(:person)
  end

  describe "GET 'edit'" do
    before do 
      create_profile_field
      create_person
      xhr :get, 'edit', :id => person.to_param
    end
    it "assigns the person" do
      assigns(:person).should == person
    end
    it "assigns the profile fields" do
      assigns(:profile_fields).should == [profile_field]
    end
    it "renders edit" do
      response.should render_template('edit')
      response.should render_template('_edit')
    end
  end

  describe "PUT 'update'" do
    before {create_person}
    context "with valid params" do
      def update 
        xhr :put, 'update', :id => person.to_param, :person => valid_parameters
      end
      it "redirects to the accounts landing page" do
        update
        response.should render_template "update"
        response.should render_template "shared/_person"
      end
      it "updates the profile" do
        update
        person.email == valid_parameters[:email]
        person.name == valid_parameters[:name]
        person.telephone == valid_parameters[:telephone]
      end
    end
    context "with invalid params" do
      before {
        xhr :put, 'update', :id => person.to_param, :person => valid_parameters.merge(:name => '')
      }
      it "renders the edit form again" do
        response.should render_template 'edit'
        response.should render_template '_edit'
      end
    end
  end

end
