require 'spec_helper'

describe Settings::ProjectsController do
  render_views
  prepare_scope :tenant
  login_as :coordinator

  def valid_parameters
    FactoryGirl.attributes_for(:project)
  end

  describe "GET 'edit'" do
    it "renders a form" do
      get 'edit'
      response.should be_success
      response.body.should have_selector("form[action='#{settings_project_path}']") 
    end
    it "puts all standard field in the form" do
      get 'edit'
      response.body.should have_selector( "form input#project_name[name='project[name]']" )
      response.body.should have_selector( "form input#project_conversation_length[name='project[conversation_length]']" )
    end
  end

  describe "PUT 'update'" do
    context "with valid params" do
      def update 
        put 'update', :project => valid_parameters
      end
      it "redirects to the projects edit" do
        update
        response.should redirect_to(edit_settings_project_path)
      end
      it "updates the project" do
        update
        active_project.name == valid_parameters[:name]
        active_project.conversation_length == valid_parameters[:conversation_length]
      end
    end
    context "with invalid params" do
      before {
        put 'update', :project => valid_parameters.merge(:name => '')
      }
      it "renders the edit form again" do
        response.should render_template :edit
      end
    end
  end

end
