class Contributor::RegistrationsController < ApplicationController
  def show
    @conversation = current_account.highest_contribution.conversation
    @location = @conversation.location
  end
end
