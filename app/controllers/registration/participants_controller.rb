class Registration::ParticipantsController < PublicController

  def new
    @person = Person.new 
    render_new
  end

  def create
    @person = Person.find_by_email(params[:person][:email]) || Person.new(params[:person])
    @person.attributes = params[:person]

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render_new
      return
    end

    if @person.save
      ParticipantAmbition.create person: @person
      if conversation
        Participant.create(:person => @person, :conversation => conversation)
        Messenger.new_participant(@person, conversation)
      else
        Messenger.new_participant_ambition(@person)
      end
      sign_in @person.account
      redirect_to confirm_registration_participants_path, notice: I18n.t('registration.participants.welcome')
    else
      render_new
    end
  end

  def confirm
    @conversations = current_person.conversations_participating_in
    @locations = @conversations.map { |c| c.location }
  end

  private 
  def render_new
    @profile_fields = ProfileField.on_form
    if conversation
      @location = conversation.location
      render action: "new" 
    else
      render action: "new_ambition"
    end
  end

  def conversation 
    @conversation ||= Conversation.find params[:conversation_id] rescue nil
  end

end
