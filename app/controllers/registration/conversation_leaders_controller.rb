class Registration::ConversationLeadersController < PublicController
  append_before_filter :check_conversation, :only => [:new, :create]

  def new
    @person = Person.new 
    render_new
  end

  def create
    @person = Person.find_by_email(params[:person][:email]) || Person.new(params[:person])
    @person.attributes = params[:person]
    # training_registrations.each do |training_id|
    #   @person.training_registrations << TrainingRegistration.new(:training_id => training_id)
    # end
    @conversation_leader = ConversationLeader.new :person => @person, :conversation => @conversation

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render_new
      return
    end

    if @conversation_leader.save
      ConversationLeaderAmbition.create person: @person
      @person.replace_training_registrations(training_registrations)
      Messenger.new_conversation_leader(@conversation_leader)
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
    @location = @conversation.location
    @profile_fields = ProfileField.on_form
    @training_types = TrainingType.all
    render action: "new" 
  end

  def check_conversation
    unless params[:conversation_id] && Conversation.exists?(params[:conversation_id])
      return head :not_found
    end
    @conversation = Conversation.find params[:conversation_id]
  end

  def training_registrations
    params[:training_registrations] && params[:training_registrations].values || []
  end
end
