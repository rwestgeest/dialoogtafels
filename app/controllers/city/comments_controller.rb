class City::CommentsController < ApplicationController
  append_before_filter :check_location

  def index
    @location_comments = @location.location_comments
  end

  def show
    @location_comment = LocationComment.find(params[:id])
  end

  def create
    @location_comment = LocationComment.new(params[:location_comment])
    @location_comment.author = current_person
    @location_comment.reference = location
    @location_comment.set_addressees(params[:notify_people])
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
