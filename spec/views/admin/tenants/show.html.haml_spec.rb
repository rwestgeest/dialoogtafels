require 'spec_helper'

describe "admin/tenants/show" do
  before(:each) do
    @tenant = assign(:tenant, stub_model(Tenant))
  end

  it "renders attributes in <p>" do
    render
  end
end
