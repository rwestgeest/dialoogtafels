class City::TrainingsController < ApplicationController
  def index
    @conversation_leaders = Person.conversation_leaders_for(active_project) 
    @trainings = Training.all
  end

  def show
    @training = Training.find(params[:id])
  end

  def new
    @training = Training.new
  end

  def edit
    @training = Training.find(params[:id])
  end

  def create
    @training = Training.new(params[:training])

    if @training.save
      redirect_to city_training_path(@training), notice: 'Training was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @training = Training.find(params[:id])

    if @training.update_attributes(params[:training])
      redirect_to city_training_path(@training), notice: 'Training was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @training = Training.find(params[:id])
    @training.destroy

    redirect_to city_trainings_url
  end
end
