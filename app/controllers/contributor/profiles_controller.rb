class Contributor::ProfilesController < ApplicationController
  def edit
    @person = current_account.person
    @profile_fields = ProfileField.order("'profile_fields.order'")
  end

  def update
    @person = current_account.person
    if @person.update_attributes(params[:person])
      redirect_to current_account.landing_page
    else
      @profile_fields = ProfileField.order("'profile_fields.order'")
      render :action => 'edit'
    end
  end
end
