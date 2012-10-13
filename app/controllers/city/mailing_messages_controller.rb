class City::MailingMessagesController < ApplicationController
  def index
    @mailing_messages = active_project.mailing_messages
  end

  def show
    @mailing_message = active_project.mailing_messages.find(params[:id])
  end

  class Mailer < Struct.new(:mailing_controller)
    def mailing(mailing_parameters, project, person)
      mailing_message = MailingMessage.new(mailing_parameters)
      mailing_message.reference = project
      mailing_message.author = person

      if mailing_message.save
        mailing_controller.mailing_success(mailing_message)
      else
        mailing_controller.mailing_failed(mailing_message)
      end
    end
  end

  def create
    Mailer.new(self).mailing(params[:mailing_message], active_project, current_person)
  end

  def mailing_success(mailing_message)
    @mailing_message = mailing_message
    render action: "create"
  end

  def mailing_failed(mailing_message)
    @mailing_message = mailing_message
    render action: "new"
  end


  def destroy
    @mailing_message = MailingMessage.find(params[:id])
    @mailing_message.destroy

    redirect_to city_mailing_messages_url 
  end
end
