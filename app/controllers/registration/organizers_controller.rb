class Registration::OrganizersController < PublicController

  def new
    @person = Person.new 
    render_new
  end

  def create
    @person = Person.find_by_email(params[:person][:email]) || Person.new(params[:person])
    @person.attributes =  params[:person]
    if Organizer.by_email(@person.email).exists?
      redirect_to new_account_session_path(:email => @person.email), :notice => "Een tafelorganisator met dit email adres bestaat al. Probeer in te loggen"
      return 
    end

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render_new
      return
    end

    if @person.save
      organizer = Organizer.create(:person => @person)
      Messenger.new_organizer(@person)
      @person.register_for_mailing
      sign_in @person.account
      redirect_to organizer.first_landing_page, notice: I18n.t('registration.organizers.welcome')
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

