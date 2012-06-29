class Settings::ProjectsController < ApplicationController
  def edit
    @project = active_project
  end

  def update
    @project = active_project
    if @project.update_attributes(params[:project])
      redirect_to edit_settings_project_path
    else
      render :action => 'edit'
    end
  end
end
