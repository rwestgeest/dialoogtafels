require 'spec_helper'

describe "registration/organizers/new" do
  before(:each) do
    assign(:organizer, stub_model(Organizer).as_new_record)
  end

  it "renders new person form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registration_organizers_path, :method => "post" do
    end
  end
end
