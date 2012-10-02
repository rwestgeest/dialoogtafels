class Registration::ConversationLeadersController < PublicController

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

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render_new
      return
    end

    @person.validate_training_registrations if active_project.obligatory_training_registration
    @person.build_training_registrations(training_registrations)
    if @person.save
      ConversationLeaderAmbition.create person: @person
      if conversation
        ConversationLeader.create :person => @person, :conversation => conversation
        Messenger.new_conversation_leader(@person, conversation)
      else
        Messenger.new_conversation_leader_ambition(@person)
      end

      @person.register_for_mailing

      sign_in @person.account
      redirect_to confirm_registration_conversation_leaders_path, notice: I18n.t('registration.conversation_leaders.welcome')
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
    @training_types = TrainingType.all
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

  def training_registrations
    params[:training_registrations] && params[:training_registrations].values || []
  end
end
