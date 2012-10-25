require 'mailing_repository'
require 'people_repository'
require 'mailing'

class City::MailingMessagesController < ApplicationController
  def index
    @mailing_messages = active_project.mailing_messages
  end

  def show
    @mailing_message = active_project.mailing_messages.find(params[:id])
  end

  def create
    begin 
      @mailing_message = MailingMessage.new(params[:mailing_message])
      mailing = Mailing.new(Postman, MailingRepository.new(self, active_project, current_person))
      mailing.create_mailing(@mailing_message, create_recepient_list(params[:to]))
      render action: "create"
    rescue RepositorySaveException => e
      @mailing_message = e.object_that_failed_to_save
      render action: "new"
    end
  end

  def destroy
    @mailing_message = MailingMessage.find(params[:id])
    @mailing_message.destroy

    redirect_to city_mailing_messages_url 
  end

  private 
  def create_recepient_list(groups)
    RecepientsBuilder.new(PeopleRepository.new(active_project)).from_groups(params[:to])
  end
end
