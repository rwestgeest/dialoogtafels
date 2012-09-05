class City::RegistrationsController < ApplicationController
  def index
    begin 
      @people = Person.order('name')
      # @people = Person.organizers_for(active_project).order(:name)
      @person = Person.find(params[:person_id])
      @active_contributions = @person.conversation_contributions_for(active_project)
      render_index
    rescue ActiveRecord::RecordNotFound
      render :action => 'select_person'
    end
  end

  def create
    begin
      @person = Person.find(params[:person_id])
      contributor = contributor_class.new :conversation_id => params[:conversation_id] 
      contributor.person = @person
      contributor.project = active_project
      contributor.save!
      @location = contributor.conversation.location
      @active_contributions = @person.conversation_contributions_for(active_project)
      render :action => 'create'
    rescue ActiveRecord::RecordNotFound => e
      logger.warn e
      head :not_found
    rescue ActiveRecord::RecordInvalid => e
      logger.warn e.record.errors.full_messages
      head :not_found
    rescue NameError => e
      logger.warn e
      head :not_found
    end
  end

  def destroy
    begin
    contributor = Contributor.find(params[:id])
    @person = contributor.person
    @location = contributor.conversation.location
    @active_contributions = @person.conversation_contributions_for(active_project)
    contributor.destroy
    render :action => 'create'
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end

  private 
  def contributor_class
    raise NameError unless %w{conversation_leader participant}.include?(params[:contribution])
    params[:contribution].camelize.constantize
  end
  def render_index
    @active_contributions = @person.conversation_contributions_for(active_project)
    @available_locations = Location.all
    render :action => 'index'
  end
end
