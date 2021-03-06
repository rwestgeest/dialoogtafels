class Admin::TenantsController < ApplicationController
  # GET /admin/tenants
  # GET /admin/tenants.json
  def index
    @tenants = Tenant.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tenants }
    end
  end

  # GET /admin/tenants/1
  # GET /admin/tenants/1.json
  def show
    @tenant = Tenant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tenant }
    end
  end

  # GET /admin/tenants/new
  # GET /admin/tenants/new.json
  def new
    @tenant = Tenant.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tenant }
    end
  end

  # GET /admin/tenants/1/edit
  def edit
    @tenant = Tenant.find(params[:id])
  end

  # POST /admin/tenants
  # POST /admin/tenants.json
  def create
    @tenant = Tenant.new(params[:tenant])

    respond_to do |format|
      if @tenant.save 
        format.html { redirect_to admin_tenant_url(@tenant), notice: 'Tenant was successfully created.' }
        format.json { render json: @tenant, status: :created, location: @tenant }
      else
        format.html { render action: "new" }
        format.json { render json: @tenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/tenants/1
  # PUT /admin/tenants/1.json
  def update
    @tenant = Tenant.find(params[:id])

    respond_to do |format|
      if @tenant.update_attributes(params[:tenant])
        format.html { redirect_to admin_tenant_url(@tenant), notice: 'Tenant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tenant.errors, status: :unprocessable_entity }
      end
    end
  end

  def notify_new
    @tenant = Tenant.find(params[:id])
    Messenger.new_tenant(@tenant)
    redirect_to admin_tenants_url, :notice => "messages sent"
  end

  # DELETE /admin/tenants/1
  # DELETE /admin/tenants/1.json
  def destroy
    @tenant = Tenant.find(params[:id])
    @tenant.destroy

    respond_to do |format|
      format.html { redirect_to admin_tenants_url }
      format.json { head :no_content }
    end
  end
end
