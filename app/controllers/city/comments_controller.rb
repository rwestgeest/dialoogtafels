class City::CommentsController < ApplicationController
  append_before_filter :check_location

  def index
    @location_comments = @location.location_comments
  end
  def create
    @location_comment = LocationComment.new(params[:location_comment])
    @location_comment.author = current_person
    if @location_comment.save
      render 'create'
    else
      render 'new'
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
