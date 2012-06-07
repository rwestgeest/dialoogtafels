class LocationsController < PublicController
  def index
    @locations = Location.all
  end

  def show
    @location = Location.find(params[:id])
  end
end
