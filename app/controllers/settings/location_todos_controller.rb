class Settings::LocationTodosController < ApplicationController

  def edit
    @location_todo = LocationTodo.find(params[:id])
  end

  def create
    @location_todo = LocationTodo.new(params[:location_todo])
    @location_todo.project = active_project
    @location_todo.save
    render :action => 'index'
  end

  def update
    @location_todo = LocationTodo.find(params[:id])
    if @location_todo.update_attributes(params[:location_todo])
      render :action => "update"
    else
      render :action => "edit"
    end
  end

  def destroy
    @location_todo = LocationTodo.find(params[:id])
    @location_todo.destroy

    render :action => 'index'
  end
end
