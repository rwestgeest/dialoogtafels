class City::MailingMessagesController < ApplicationController
  def index
    @mailing_messages = active_project.mailing_messages
  end

  def show
    @mailing_message = active_project.mailing_messages.find(params[:id])
  end

  def create
    @mailing_message = MailingMessage.new(params[:mailing_message])
    @mailing_message.reference = active_project
    @mailing_message.author = current_person

    if @mailing_message.save
      render action: "create"
    else
      render action: "new"
    end
  end

  def destroy
    @mailing_message = MailingMessage.find(params[:id])
    @mailing_message.destroy

    redirect_to city_mailing_messages_url 
  end
end
