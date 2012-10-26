require 'mailing_repository'
require 'people_repository'
require 'mailing'

class City::MailingMessagesController < ApplicationController
  def index
    @mailing_messages = mailing_repository.mailing_messages
    @mailing_message = MailingMessage.new
  end

  def show
    @mailing_message = mailing_repository.mailing_messages.find(params[:id])
  end

  def create
    begin 
      @mailing_message = Mailing.new(MailingScheduler.new(Tenant.current, Postman, Delayed::Job), recepient_list, mailing_repository).create_mailing(MailingMessage.new(params[:mailing_message]))
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

  def mailing_repository
    @mailing_repository ||= MailingRepository.new(active_project, current_person)
  end

  def recepient_list
    @recepient_list ||= RecipientsBuilder.new(PeopleRepository.new(active_project)).from_groups(params[:mailing_message][:groups])
  end

end
