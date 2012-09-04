class Registration::OrganizersController < PublicController

  def new
    @person = Person.new 
    render_new
  end

  def create
    @person = Person.new(params[:person])
    @organizer = Organizer.new(:person => @person)
    if Organizer.by_email(@person.email).exists?
      redirect_to new_account_session_path(:email => @person.email), :notice => "Een tafelorganisator met dit email adres bestaat al. Probeer in te loggen"
      return 
    end

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render_new
      return
    end

    if @organizer.save
      Messenger.new_organizer(@organizer)
      sign_in @organizer.account
      redirect_to @organizer.first_landing_page, notice: I18n.t('registration.organizers.welcome')
    else
      render_new
    end
  end

  private 
  def render_new
    @profile_fields = ProfileField.on_form
    render action: "new" 
  end
end

