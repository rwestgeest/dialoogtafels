class City::TrainingInvitationsController < ApplicationController
  append_before_filter :check_training
  def index
    @training_invitations = @training.training_invitations
  end
  def create
    @training_invitation = TrainingInvitation.new(params[:training_invitation])
    @training_invitation.author = current_person
    @training_invitation.reference = training
    @training_invitation.set_addressees(params[:notify_people])
    if (@training_invitation.save)
      render 'create'
    else
      render 'new'
    end
  end

  private 
  def check_training
     unless training
      head :not_found
     end
  end
  def training
      @training ||= Training.find(params[:training_id]) rescue nil
  end
end
