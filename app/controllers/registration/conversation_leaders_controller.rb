class Registration::ConversationLeadersController < PublicController
  append_before_filter :check_conversation, :only => :new

  def new
    @conversation_leader = ConversationLeader.new conversation_id: params[:conversation_id]
    render_new
  end

  def create
    @conversation_leader = ConversationLeader.new(params[:conversation_leader])

    if @conversation_leader.save
      sign_in @conversation_leader.account
      redirect_to confirm_registration_conversation_leaders_url, notice: I18n.t('registration.conversation_leaders.welcome')
    else
      render_new
    end
  end

  def confirm
    @conversation = current_account.active_contribution.conversation
    @location = @conversation.location
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
