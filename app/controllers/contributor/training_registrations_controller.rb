class Contributor::TrainingRegistrationsController < ApplicationController
  def index
    @attendee = current_conversation_leader
    @attendees = ConversationLeader.all
    @available_trainings = Training.all - @attendee.trainings
    render :index
  end
  def create
    @attendee = current_conversation_leader
    @attendee.register_for(params[:training_id])
    render_index
  end
  def destroy
    @attendee = current_conversation_leader
    @attendee.cancel_registration_for(params[:id])
    render_index
  end
  def render_index
    @available_trainings = Training.all - @attendee.trainings
    render :index
  end
end
