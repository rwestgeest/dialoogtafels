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
    render_edit 
  end

  def create
    @location = Location.new(params[:location])
    @location.organizer = current_organizer
      if @location.save
        redirect_to edit_organizer_location_url(@location, :step=>'conversations'), notice: 'Locatie aangemaakt voeg nu dialooggesprekken toe.' 
      else
        render action: "new" 
      end
  end

  def update
    @location = Location.find(params[:id])

    if @location.update_attributes(params[:location])
      redirect_to organizer_location_url(@location), notice: 'Locatie succesvol bijgewerkt.' 
    else
      render_edit
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    redirect_to organizer_locations_url 
  end

  private 
  def render_edit
    return render(action: "step_#{params[:step]}") if %w(conversations publication).include?(params[:step])
    render(action: 'edit')
  end
end
