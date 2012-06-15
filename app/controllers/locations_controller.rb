class LocationsController < PublicController
  def index
    @locations = Location.publisheds
  end

  def show
    begin
      @location = Location.publisheds.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end
end
