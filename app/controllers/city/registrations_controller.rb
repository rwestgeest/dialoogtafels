class City::RegistrationsController < ApplicationController
  def index
    begin 
      @people = Person.all
      @person = Person.find(params[:person_id])
      @active_contributions = @person.active_contributions_for(active_project)
      render_index
    rescue ActiveRecord::RecordNotFound
      render :action => 'select_person'
    end
  end
  def create
    @person = Person.find(params[:person_id])
    contributor = ConversationLeader.new :conversation_id => params[:conversation_id] 
    contributor.person = @person
    contributor.project = active_project
    contributor.save
    render_index
  end

  def destroy
    begin
    contributor = Contributor.find(params[:id])
    @person = contributor.person
    contributor.destroy
    render_index
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end
  private 
  def render_index
    @active_contributions = @person.active_contributions_for(active_project)
    @available_locations = Location.all
    render :action => 'index'
  end
end
