class City::TrainingRegistrationsController < ApplicationController
  def index
    begin 
      @attendees = Person.conversation_leaders_for(active_project)
      @attendee = Person.find(params[:attendee_id])
      render_index
    rescue ActiveRecord::RecordNotFound
      render :action => 'select_attendee'
    end
  end
  def create
    @attendee = Person.find(params[:attendee_id])
    @attendee.register_for(params[:training_id])
    render_index
  end
  def destroy
    @attendee = Person.find(params[:attendee_id])
    @attendee.cancel_registration_for(params[:id])
    render_index
  end
  private
  def render_index
    @available_trainings = Training.availables - @attendee.trainings
    render :index
  end
end
