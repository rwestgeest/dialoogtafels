class City::TrainingRegistrationsController < ApplicationController
  def show
    begin 
      @attendees = Person.conversation_leaders_for(active_project).order(:name)
      @attendee = Person.find(params[:id])
      @training_types = TrainingType.all
      render :show
    rescue ActiveRecord::RecordNotFound
      render :action => 'select_attendee'
    end
  end

  def update
    @attendee = Person.find(params[:id])
    @attendee.replace_training_registrations params[:training_registrations].values
    redirect_to city_training_registration_path(params[:id]), notice: 'Inschrijvingen bijgewerkt'
  end
end
