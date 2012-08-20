class Contributor::TrainingRegistrationsController < ApplicationController
  def show
    @attendee = current_person
    @training_types = TrainingType.all
    render :show
  end

  def update
    @attendee = current_person
    @attendee.replace_training_registrations params[:training_registrations].values
    redirect_to contributor_training_registrations_path, notice: "Trainingen bijgewerkt"
  end

end
