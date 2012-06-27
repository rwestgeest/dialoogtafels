class Contributor::TrainingRegistrationsController < ApplicationController
  def index
    @attendee = current_person
    @available_trainings = Training.all - @attendee.trainings
    render :index
  end
  def create
    @attendee = current_person
    @attendee.register_for(params[:training_id])
    render_index
  end
  def destroy
    @attendee = current_person
    @attendee.cancel_registration_for(params[:id])
    render_index
  end
  def render_index
    @available_trainings = Training.all - @attendee.trainings
    render :index
  end
end
