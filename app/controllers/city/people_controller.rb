class City::PeopleController < ApplicationController
  def edit
    @person = Person.find(params[:id])
    @profile_fields = ProfileField.order("'profile_fields.order'")
  end
  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person]) 
      render :action => 'update' 
    else
      @profile_fields = ProfileField.order("'profile_fields.order'")
      render :action => 'edit' 
    end

  end
end
