class Registration::OrganizersController < ApplicationController

  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @organizer = Organizer.new
  end

  def create
    @organizer = Organizer.new(params[:person])

    if @organizer.save
      redirect_to confirm_registration_organizers_url, notice: 'Organizer was successfully created.' 
    else
      render action: "new" 
    end
  end

end
