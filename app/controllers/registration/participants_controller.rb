class Registration::ParticipantsController < ApplicationController
  layout 'registration'

  def new
    @participant = Participant.new
  end

  def create
    @participant = Participant.new(params[:participant])

    if @participant.save
      redirect_to confirm_registration_participants_url, notice: I18n.t('registration.participants.welcome')
    else
      render action: "new" 
    end
  end
  def confirm
  end
end
