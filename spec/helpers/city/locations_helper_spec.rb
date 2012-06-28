require 'spec_helper'

describe City::LocationsHelper do
  include City::LocationsHelper
  include Menu::RequestParams
  def link_to(*args) 
    "the_link"
  end
  def request
    stub(:parameters => @current_request_params)
  end
  describe 'aspect_link' do
    it "renders link " do
      @current_request_params = request_params_for("city/locations#show")
      aspect_link("city/locations#edit", "link_name").should == "the_link"
    end
    it "renders selected text if path matches" do
      @current_request_params = request_params_for("city/locations#show")
      aspect_link("city/locations#show", "link_name").should == "<span class=\"selected-text\">link_name</span>"
    end
    it "renders selected text if path matche partially" do
      @current_request_params = request_params_for("city/locations#show")
      aspect_link("city/locations", "link_name").should == "<span class=\"selected-text\">link_name</span>"
    end
  end

end
