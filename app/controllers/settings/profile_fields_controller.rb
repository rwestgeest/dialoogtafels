class Settings::ProfileFieldsController < ApplicationController
  def index
    @profile_fields = ProfileField.all
  end

  def new
    @profile_field = ProfileStringField.new
  end

  def edit
    @profile_field = ProfileField.find(params[:id])
  end

  def create
    @profile_field = ProfileField.new(params[:profile_field])

    if @profile_field.save
      @profile_fields = ProfileField.all
      render action: "index" 
    else
      render action: "new" 
    end
  end

  def update
    @profile_field = ProfileField.find(params[:id])
    if @profile_field.update_attributes(params[:profile_field])
      @profile_field = ProfileField.find(params[:id]) # make sure that the class changes
      render action: "show" 
    else
      render action: "edit" 
    end
  end

  def sort
    params[:profile_field].select{|field_id| field_id.to_i != 0 }.each_with_index do |field_index, order|
      ProfileField.find(field_index).update_attribute :order, order rescue ActiveRecord::RecordNotFound
    end
    render nothing: true
  end

  def destroy
    @profile_field = ProfileField.find(params[:id])
    @profile_field.destroy

    @profile_fields = ProfileField.all
    render :action => 'index'
  end
end
