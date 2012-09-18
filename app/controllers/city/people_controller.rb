class City::PeopleController < ApplicationController

  def index
    @people = Person.filter(params['people_filter']).call(active_project).order(:name)
  end

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
  def destroy
    @person_id = params[:id]
    Person.destroy(@person_id)
    render action: 'destroy'
  end
end
