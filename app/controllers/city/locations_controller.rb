class City::LocationsController < ApplicationController
  def index
    @locations = Location.all
  end

  def show
    @location = Location.find(params[:id])
  end

  def new
    if params[:organizer_id] 
      @location = Location.new :organizer_id => params[:organizer_id]
      render :action => 'new'
    else
      @organizers = Organizer.all
      render :action => 'select_organizer'
    end
  end

  def edit
    @location = Location.find(params[:id])
    render_edit
  end

  def create
    @location = Location.new(params[:location])

    if @location.save
      redirect_to edit_city_location_path(@location, :step => 'conversations'), notice: 'Locatie is succesvol aangemaakt.' 
    else
      render action: "new" 
    end
  end

  def update
    @location = Location.find(params[:id])

    if @location.update_attributes(params[:location])
      redirect_to city_location_path(@location), notice: 'Location is sucesvol bijgewerkt.' 
    else
      render_edit
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    redirect_to city_locations_url
  end

  private 
  def render_edit
    return render(action: "step_#{params[:step]}") if %w(conversations publication).include?(params[:step])
    render(action: 'edit')
  end
end
