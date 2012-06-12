class Organizer::LocationsController < ApplicationController
  def index
    @locations = Location.where(:organizer_id => current_organizer)
  end

  def new
    @location = Location.new
  end

  def show
    @location = Location.find(params[:id])
  end

  def create
    @location = Location.new(params[:location])
    @location.organizer = current_organizer
      if @location.save
        redirect_to edit_city_location_url(@location, :step=>'conversations'), notice: 'Locatie aangemaakt voeg nu dialooggesprekken toe.' 
      else
        render action: "new" 
      end
  end

end
