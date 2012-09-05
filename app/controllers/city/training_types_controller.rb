class City::TrainingTypesController < ApplicationController
  def index
    @training_types = TrainingType.all
    @people = Person.conversation_leaders_for(active_project).order(:name)
  end

  def show
    @training_type = TrainingType.find(params[:id])
  end

  def new
    @training_type = TrainingType.new
  end

  def edit
    @training_type = TrainingType.find(params[:id])
  end

  def create
    @training_type = TrainingType.new(params[:training_type])

    if @training_type.save
      redirect_to city_training_type_path(@training_type), notice: 'Nieuwe training is succesvol toegevoegd.' 
    else
      render action: "new"
    end
  end

  def update
    @training_type = TrainingType.find(params[:id])

    if @training_type.update_attributes(params[:training_type])
      redirect_to city_training_type_path(@training_type), notice: 'Training type is successvol bigewerkt.'
    else
      render action: "edit" 
    end
  end

  def destroy
    @training_type = TrainingType.find(params[:id])
    @training_type.destroy

    redirect_to city_training_types_path
  end
end
