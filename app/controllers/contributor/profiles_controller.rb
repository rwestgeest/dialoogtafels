class Contributor::ProfilesController < ApplicationController
  def edit
    @person = current_account.person
  end

  def update
    @person = current_account.person
    if @person.update_attributes(params[:person])
      redirect_to current_account.landing_page
    else
      render :action => 'edit'
    end
  end
end
