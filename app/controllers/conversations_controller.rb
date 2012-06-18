class ConversationsController < ApplicationController
  append_before_filter :check_location, :only => :new
  def show
    @conversation = Conversation.find(params[:id])
  end

  def new
    @conversation = Conversation.new(:location_id => params[:location_id])
  end

  def edit
    @conversation = Conversation.find(params[:id])
  end

  def create
    @conversation = Conversation.new(params[:conversation])

    if @conversation.save
      @conversations = @conversation.location.conversations
      @location = @conversation.location
      render :action => 'index'
    else
      render :action => 'new'
    end
  end

  def update
    @conversation = Conversation.find(params[:id])

    if @conversation.update_attributes(params[:conversation])
      render :action => 'show'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @conversation = Conversation.find(params[:id])
    @conversations = @conversation.location.conversations
    @conversation.destroy
    @location = @conversation.location
    render :action => 'index'
  end

  def check_location
     unless params[:location_id] && Location.exists?(params[:location_id])
      head :not_found
     end
  end
end
