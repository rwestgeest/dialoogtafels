module City::TrainingInvitationsHelper
  include ::MessagesHelper
  def render_invitation(invitation)
    render partial: 'training_invitation', locals: {training_invitation: invitation}
  end
  def new_training_invitation_form(training)
    render :partial => '/city/training_invitations/new_training_invitation_form', locals: {training: training}
  end
end
