class Organizer::LocationsController < ApplicationController
  def index
    @locations = Location.where(:organizer_id => current_organizer)
  end

  def show
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def edit
    @location = Location.find(params[:id])
  end

  def create
    @location = Location.new(params[:location])
    @location.organizer = current_organizer

      if @location.save
        redirect_to organizer_location_url(@location), notice: 'Location was successfully created.' 
      else
        render action: "new" 
      end
  end

  def update
    @location = Location.find(params[:id])

      if @location.update_attributes(params[:location])
        redirect_to organizer_location_url(@location), notice: 'Location was successfully updated.' 
      else
        render action: "edit" 
      end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    redirect_to organizer_locations_url 
  end
end
