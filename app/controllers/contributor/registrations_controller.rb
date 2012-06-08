class Contributor::RegistrationsController < ApplicationController
  def show
    @conversation = current_account.active_contribution.conversation
    @location = @conversation.location
  end
end
