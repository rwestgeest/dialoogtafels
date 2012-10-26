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
    return test if params[:commit] == 'test'
    begin 
      @mailing_message = Mailing.new(mailing_scheduler, recepient_list, mailing_repository).create_mailing(MailingMessage.new(params[:mailing_message]))
      flash[:notice] = "Mail verzonden" 
      render action: "create"
    rescue RepositorySaveException => e
      @mailing_message = e.object_that_failed_to_save
      render action: "new"
    end
  end

  def test
    begin
      @mailing_message = Mailing.new(direct_mailing_scheduler, test_recepient_list, mailing_validator).create_mailing(MailingMessage.new(params[:mailing_message]))
      flash[:notice] = "Test mail verzonden" 
      render action: "new"
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

  def mailing_validator
    @mailing_repository ||= MailingRepository.validator(active_project, current_person)
  end

  def mailing_scheduler
    @mailing_scheduler ||= MailingScheduler.new(Tenant.current, Postman, Delayed::Job)
  end

  def direct_mailing_scheduler
    @mailing_scheduler ||= MailingScheduler.direct(Postman)
  end

  def test_recepient_list
    @test_recipient_list ||= RecipientsBuilder.new(PeopleRepository.new(active_project)).from_groups(['coordinators'])
  end

  def recepient_list
    @recipient_list ||= RecipientsBuilder.new(PeopleRepository.new(active_project)).from_groups(params[:mailing_message][:groups])
  end

end
