class City::LocationsController < ApplicationController
  def index
    @locations = active_project.locations
    if params[:todo] 
      @selected_todo = active_project.location_todos.find(params[:todo]) 
      finished_location_ids = @selected_todo.finished_location_todos.map {|finished_locaiton_todo| finished_locaiton_todo.location_id}
      @locations = @locations.where("locations.id not in (?)", finished_location_ids)
    end
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

  def organizer
    @location = Location.find(params[:id])
    @organizers = Organizer.all
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
