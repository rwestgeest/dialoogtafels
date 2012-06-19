require 'spec_helper'

describe Contributor::ProfilesController do
  render_views
  prepare_scope :tenant
  login_as :organizer

  def valid_parameters
    FactoryGirl.attributes_for(:person)
  end

  describe "GET 'edit'" do
    it "renders a form" do
      get 'edit'
      response.should be_success
      response.body.should have_selector("form[action='#{contributor_profile_path}']") 
    end
    it "puts all standard field in the form" do
      get 'edit'
      response.body.should have_selector( "form input#person_name[name='person[name]']" )
      response.body.should have_selector( "form input#person_telephone[name='person[telephone]']" )
      response.body.should have_selector( "form input#person_email[name='person[email]']" )
    end
    it "puts all possible profile fields in the form" do
      FactoryGirl.create :profile_string_field, :label => 'age'
      FactoryGirl.create :profile_string_field, :label => 'diet'
      get 'edit'
      response.body.should have_selector( "form input#person_profile_age[name='person[profile_age]']")
      response.body.should have_selector( "form input#person_profile_diet[name='person[profile_diet]']")
    end
  end

  describe "PUT 'update'" do
    context "with valid params" do
      def update 
        put 'update', :person => valid_parameters
      end
      it "redirects to the accounts landing page" do
        update
        response.should redirect_to(current_account.landing_page)
      end
      it "updates the profile" do
        update
        current_account.person.email == valid_parameters[:email]
        current_account.person.name == valid_parameters[:name]
        current_account.person.telephone == valid_parameters[:telephone]
      end
    end
    context "with invalid params" do
      before {
        put 'update', :person => valid_parameters.merge(:name => '')
      }
      it "renders the edit form again" do
        response.should render_template :edit
      end
    end
  end

end
