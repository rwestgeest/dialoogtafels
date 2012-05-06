require 'spec_helper'

describe "admin/tenants/new" do
  before(:each) do
    assign(:tenant, stub_model(Tenant).as_new_record)
  end

  it "renders new tenant form" do
    render

    rendered.should have_selector("form", :action => admin_tenants_path, :method => "post") do |form|
    end
  end
end
