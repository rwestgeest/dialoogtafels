require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Admin::TenantsController do
  login_as :maintainer

  # This should return the minimal set of attributes required to create a valid
  # Tenant. As you add validations to Tenant, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    FactoryGirl.attributes_for :tenant
  end
  
  describe "GET index" do
    it "assigns all tenants as @tenants" do
      tenant = Tenant.create! valid_attributes
      get :index, {}
      assigns(:tenants).should eq([tenant])
    end
  end

  describe "GET show" do
    it "assigns the requested tenant as @tenant" do
      tenant = Tenant.create! valid_attributes
      get :show, {:id => tenant.to_param}
      assigns(:tenant).should eq(tenant)
    end
  end

  describe "GET new" do
    it "assigns a new tenant as @tenant" do
      get :new, {}
      assigns(:tenant).should be_a_new(Tenant)
    end
  end

  describe "GET edit" do
    it "assigns the requested tenant as @tenant" do
      tenant = Tenant.create! valid_attributes
      get :edit, {:id => tenant.to_param}
      assigns(:tenant).should eq(tenant)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Tenant" do
        expect {
          post :create, {:tenant => valid_attributes}
        }.to change(Tenant, :count).by(1)
      end

      it "assigns a newly created tenant as @tenant" do
        post :create, {:tenant => valid_attributes}
        assigns(:tenant).should be_a(Tenant)
        assigns(:tenant).should be_persisted
      end

      it "redirects to the created tenant" do
        post :create, {:tenant => valid_attributes}
        response.should redirect_to(admin_tenant_url(Tenant.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved tenant as @tenant" do
        # Trigger the behavior that occurs when invalid params are submitted
        Tenant.any_instance.stub(:save).and_return(false)
        post :create, {:tenant => {}}
        assigns(:tenant).should be_a_new(Tenant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Tenant.any_instance.stub(:save).and_return(false)
        post :create, {:tenant => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested tenant" do
        tenant = Tenant.create! valid_attributes
        # Assuming there are no other tenants in the database, this
        # specifies that the Tenant created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Tenant.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => tenant.to_param, :tenant => {'these' => 'params'}}
      end

      it "assigns the requested tenant as @tenant" do
        tenant = Tenant.create! valid_attributes
        put :update, {:id => tenant.to_param, :tenant => valid_attributes}
        assigns(:tenant).should eq(tenant)
      end

      it "redirects to the tenant" do
        tenant = Tenant.create! valid_attributes
        put :update, {:id => tenant.to_param, :tenant => valid_attributes}
        response.should redirect_to(admin_tenant_url(tenant))
      end
    end

    describe "with invalid params" do
      it "assigns the tenant as @tenant" do
        tenant = Tenant.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tenant.any_instance.stub(:save).and_return(false)
        put :update, {:id => tenant.to_param, :tenant => {}}
        assigns(:tenant).should eq(tenant)
      end

      it "re-renders the 'edit' template" do
        tenant = Tenant.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Tenant.any_instance.stub(:save).and_return(false)
        put :update, {:id => tenant.to_param, :tenant => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "PUT notify new" do
    let!(:tenant) { Tenant.create! valid_attributes }
    def do_post
      put :notify_new, :id => tenant
    end
    it "sends a message notification" do
      Messenger.should_receive :new_tenant, tenant
      do_post
    end
    it "redirects back to the list" do
      do_post
      response.should redirect_to admin_tenants_url
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested tenant" do
      tenant = Tenant.create! valid_attributes
      expect {
        delete :destroy, {:id => tenant.to_param}
      }.to change(Tenant, :count).by(-1)
    end

    it "redirects to the tenants list" do
      tenant = Tenant.create! valid_attributes
      delete :destroy, {:id => tenant.to_param}
      response.should redirect_to(admin_tenants_url)
    end
  end

end
