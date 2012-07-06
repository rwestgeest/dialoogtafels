class Registration::OrganizersController < PublicController

  def new
    @organizer = Organizer.new
  end

  def create
    @organizer = Organizer.new(params[:organizer])

    unless Captcha.verified?(self)
      flash.alert = I18n.t('registration.captcha_error')
      render :action => 'new'
      return
    end

    if @organizer.save
      sign_in @organizer.account
      redirect_to new_organizer_location_url, notice: I18n.t('registration.organizers.welcome')
    else
      render action: "new" 
    end
  end

end
