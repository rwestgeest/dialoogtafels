require 'spec_helper'

describe Contributor::RegistrationsController do
  render_views
  prepare_scope :tenant
  login_as :participant

  let(:contributor) { current_account.active_contribution }
  let(:conversation) { contributor.conversation }
  let(:location) { conversation.location }
  def valid_parameters
    FactoryGirl.attributes_for(:person)
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
    it "renders the location" do
      get 'show' 
      response.body.should include(location.name)
    end
  end

end