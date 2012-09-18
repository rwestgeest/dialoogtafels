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

  describe "XHR GET 'index'" do

    before { create_person }
    it "assigns the people" do
      xhr :get, 'index'
      assigns(:people).should include person
    end

    context "when called with filter" do
      it "returns the filtered people" do
        xhr :get, 'index', :people_filter => 'all'
        assigns(:people).should include person
      end
    end
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

  describe "XHR put 'update'" do
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

  describe "XHR delete destroy" do
    let!(:person) { create_person }

    def do_delete
      xhr :delete, :destroy, id: person.to_param
    end
    it "destroye the requested person" do
      expect { do_delete }.to change(Person, :count).by(-1)
    end
    it "renders the destroy" do
      do_delete
      assigns(:person_id).should == person.to_param
      response.should render_template('destroy')
    end
    context "when person organizes locations" do
      before do
        organizer = FactoryGirl.create :organizer, person: person
        FactoryGirl.create :location, organizer: organizer
      end
      it "does not remove the person" do
        expect { do_delete }.not_to change(Person, :count)
      end
      it "renders refuse_to_destroy" do
        do_delete
        assigns(:message).should == I18n.t('city.people.destroy.organizes_locations', person_name: person.name)
        response.should render_template(:destroy)
      end
    end  
  end

end
