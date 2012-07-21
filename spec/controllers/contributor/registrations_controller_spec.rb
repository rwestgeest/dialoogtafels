require 'spec_helper'

describe Contributor::RegistrationsController do
  render_views
  prepare_scope :tenant
  login_as :participant

  let(:contributor) { current_account.highest_contribution}
  let(:conversation) { contributor.conversation }
  let(:location) { conversation.location }
  def valid_parameters
    FactoryGirl.attributes_for(:person)
  end

  describe "GET 'show'" do
    let!(:conversation_leader) { FactoryGirl.create :conversation_leader, person: current_account.person }
    let(:conversations_where_i_participate) { current_account.person.conversations_participating_in_as_participant }
    let(:conversations_which_i_lead ) { current_account.person.conversations_participating_in }
    let(:conversations) { (conversations_where_i_participate + conversations_which_i_lead).uniq }
    let(:locations) { conversations.map {|c| c.location} }

    it "returns http success" do
      get 'show'
      response.should be_success
    end
    it "assigns the conversations" do
      get 'show'
      assigns(:conversations).sort.should == conversations.sort
    end
    it "renders the location" do
      get 'show' 
      locations.each do  |location |
        response.body.should include(location.name)
      end
    end
  end

end
