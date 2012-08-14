class City::TrainingsController < ApplicationController
  append_before_filter :check_training_type
  def index
    @conversation_leaders = Person.conversation_leaders_for(active_project) 
    @trainings = @training_type.trainings
  end

  def show
    @training = @training_type.trainings.find(params[:id])
  end

  def new
    @training = @training_type.trainings.new
  end

  def edit
    @training = @training_type.trainings.find(params[:id])
  end

  def create
    @training = @training_type.trainings.build(params[:training])

    if @training.save
      redirect_to city_training_path(@training), notice: 'Training is aangemaakt'
    else
      render action: "new"
    end
  end

  def update
    @training = @training_type.trainings.find(params[:id])

    if @training.update_attributes(params[:training])
      redirect_to city_training_path(@training), notice: 'Training is bijgewerkt'
    else
      render action: "edit"
    end
  end

  def destroy
    @training = Training.find(params[:id])
    @training.destroy

    redirect_to city_trainings_url
  end
  private 
  def check_training_type
    unless params[:training_type_id] && TrainingType.exists?(params[:training_type_id])
      head :not_found
    end
    @training_type = TrainingType.find(params[:training_type_id])
  end
end
