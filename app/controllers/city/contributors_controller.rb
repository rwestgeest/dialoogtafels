class City::ContributorsController < ApplicationController
  append_before_filter :check_location
  def index
    @conversation_leaders = location.conversation_leaders
    @participants = location.participants
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
