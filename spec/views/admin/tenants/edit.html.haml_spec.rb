require 'spec_helper'

describe "admin/tenants/edit" do
  before(:each) do
    @tenant = assign(:tenant, stub_model(Tenant))
  end

  it "renders the edit tenant form" do
    render

    rendered.should have_selector("form", :action => admin_tenant_path(@tenant), :method => "post") do |form|
    end
  end
end
