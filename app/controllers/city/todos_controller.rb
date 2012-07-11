class City::TodosController < ApplicationController
  append_before_filter :check_location
  def index
  end
  def update
    @todos = active_project.location_todos
    if params[:checked] == 'true'
      location.tick_done(params[:id])
    else
      location.tick_undone(params[:id])
    end
  end
  private 
  def check_location
     unless location
      head :not_found
     end
  end
  def location
      @location ||= Location.find(params[:location_id]) rescue nil
  end
end
