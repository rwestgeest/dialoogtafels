class Registration::OrganizersController < ApplicationController


  def new
    @organizer = Organizer.new
  end

  def create
    @organizer = Organizer.new(params[:organizer])

    if @organizer.save
      redirect_to confirm_registration_organizers_url, notice: 'Organizer was successfully created.' 
    else
      render action: "new" 
    end
  end
  def confirm

  end

end
