class ConversationsController < ApplicationController

  def show
    @conversation = Conversation.find(params[:id])
  end

  def new
    render :status => :not_found unless params[:location]
    @conversation = Conversation.new(:location_id => params[:location])
  end

  def edit
    @conversation = Conversation.find(params[:id])
  end

  def create
    @conversation = Conversation.new(params[:conversation])

    if @conversation.save
      @conversations = Conversation.where(:location_id => @conversation.location.to_param)
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
    @conversations = Conversation.where(:location_id => @conversation.location.to_param)
    @conversation.destroy
    render :action => 'index'
  end
end
