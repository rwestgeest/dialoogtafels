class City::CommentsController < ApplicationController
  def index
    @location_comments = Location.find(params[:location_id]).location_comments
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

end
