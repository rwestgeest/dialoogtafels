class LocationsController < PublicController
  def index
    @location_grouper = LocationGrouping.group_by(active_project.grouping_strategy, Location.publisheds)
  end

  def map
    @locations = Location.publisheds(include: :conversations)
  end

  def participant
    @location_grouper = LocationGrouping.group_by(active_project.grouping_strategy, Location.availables_for_participants)
  end

  def conversation_leader
    @location_grouper = LocationGrouping.group_by(active_project.grouping_strategy, Location.publisheds_for_conversation_leaders)
  end

  def show
    begin
      @location = Location.publisheds.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end
end
