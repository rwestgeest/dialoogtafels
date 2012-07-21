class Contributor::RegistrationsController < ApplicationController
  def show
    @conversations = current_participant.person.conversations_participating_in
  end
end
