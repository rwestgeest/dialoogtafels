class Registration::ConversationLeadersController < PublicController
  append_before_filter :check_conversation, :only => :new

  def new
    @conversation_leader = ConversationLeader.new conversation_id: params[:conversation_id]
    render_new
  end

  def create
    @conversation_leader = ConversationLeader.new(params[:conversation_leader])

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render_new
      return
    end

    if @conversation_leader.save_with_notification
      sign_in @conversation_leader.account
      redirect_to confirm_registration_conversation_leaders_path, notice: I18n.t('registration.conversation_leaders.welcome')
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
    @conversation = @conversation_leader.conversation
    @location = @conversation.location
    render action: "new" 
  end

  def check_conversation
     unless params[:conversation_id] && Conversation.exists?(params[:conversation_id])
      head :not_found
     end
  end
end
