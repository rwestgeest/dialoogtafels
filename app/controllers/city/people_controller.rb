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
    person = Person.find(@person_id)
    if person.organized_locations.empty?
      person.destroy
      render action: 'destroy'
    else
      @message = I18n.t('city.people.destroy.organizes_locations', person_name: person.name)
      render action: 'refused_to_destroy'
    end
  end
end
