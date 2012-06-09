class Registration::OrganizersController < PublicController

  def new
    @organizer = Organizer.new
  end

  def create
    @organizer = Organizer.new(params[:organizer])

    if @organizer.save
      sign_in @organizer.account
      redirect_to organizer_locations_url, notice: I18n.t('registration.organizers.welcome')
    else
      render action: "new" 
    end
  end

end
