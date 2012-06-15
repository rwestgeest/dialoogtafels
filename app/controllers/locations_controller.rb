class LocationsController < PublicController
  def index
    @locations = Location.publisheds
  end

  def show
    @location = Location.find(params[:id])
  end
end
