require 'spec_helper'

describe Contributor::ProfilesController do
  render_views
  prepare_scope :tenant
  login_as :organizer

  def valid_parameters
    FactoryGirl.attributes_for(:person)
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
      response.body.should have_selector("form[action='#{contributor_profile_path}']") do |form|
        form.should have_selector['input@contributor_name']
      end
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
