class Registration::ParticipantsController < PublicController
  append_before_filter :check_conversation, :only => :new

  def new
    @participant = Participant.new conversation_id: params[:conversation_id]
    render_new
  end

  def create
    @participant = Participant.new(params[:participant])

    if @participant.save
      redirect_to confirm_registration_participants_url, notice: I18n.t('registration.participants.welcome')
    else
      render_new
    end
  end

  def confirm
  end

  private 
  def render_new
    @conversation = @participant.conversation
    @location = @conversation.location
    render action: "new" 
  end

  def check_conversation
     unless params[:conversation_id] && Conversation.exists?(params[:conversation_id])
      head :not_found
     end
  end
end
