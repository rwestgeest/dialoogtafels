class Registration::OrganizersController < PublicController

  def new
    @organizer = Organizer.new
  end

  def create
    @organizer = Organizer.new(params[:organizer])

    if Organizer.by_email(@organizer.email).exists?
      redirect_to new_account_session_path(:email => @organizer.email), :notice => "Een tafelorganisator met dit email adres bestaat al. Probeer in te loggen"
      return 
    end

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render :action => 'new'
      return
    end

    if @organizer.save
      sign_in @organizer.account
      redirect_to @organizer.first_landing_page, notice: I18n.t('registration.organizers.welcome')
    else
      render action: "new" 
    end
  end
end
