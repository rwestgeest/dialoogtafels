class Registration::ParticipantsController < PublicController
  append_before_filter :check_conversation, :only => [ :new, :create ]

  def new
    @person = Person.new 
    render_new
  end

  def create
    @person = Person.find_by_email(params[:person][:email]) || Person.new(params[:person])
    @person.attributes = params[:person]
    @participant = Participant.new(:person => @person, :conversation => @conversation)

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render_new
      return
    end

    if @participant.save
      ParticipantAmbition.create person: @person
      Messenger.new_participant(@participant)
      sign_in @participant.account
      redirect_to confirm_registration_participants_path, notice: I18n.t('registration.participants.welcome')
    else
      render_new
    end
  end

  def confirm
    @conversations = current_participant.person.conversations_participating_in
    @locations = @conversations.map { |c| c.location }
  end

  private 
  def render_new
    @location = @conversation.location
    @profile_fields = ProfileField.on_form
    render action: "new" 
  end

  def check_conversation
    unless params[:conversation_id] && Conversation.exists?(params[:conversation_id])
      return head :not_found
    end
    @conversation = Conversation.find params[:conversation_id]
  end
end
