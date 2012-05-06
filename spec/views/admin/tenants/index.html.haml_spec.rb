require 'spec_helper'

describe "admin/tenants/index" do
  before(:each) do
    assign(:tenants, [
      stub_model(Tenant),
      stub_model(Tenant)
    ])
  end

  it "renders a list of admin/tenants" do
    render
  end
end
