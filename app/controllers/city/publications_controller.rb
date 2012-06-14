class City::PublicationsController < ApplicationController
  append_before_filter :check_location

  def show
    @location = Location.find(params[:location_id])
  end

  def new
    @location = Location.find(params[:location_id])
  end

  def edit
    @location = Location.find(params[:location_id])
  end

  def create
    @location = Location.find(params[:location_id])

    if @location.update_attributes(params[:location])
      redirect_to city_location_publication_path(:location_id => @location.to_param), notice: 'Publicatie is aangemaakt.' 
    else
      render action: "new" 
    end
  end

  def update
    @location = Location.find(params[:location_id])

    if @location.update_attributes(params[:location])
      redirect_to city_location_publication_path(:location_id => @location.to_param), notice: 'Publication is bijgewerkt.' 
    else
      render action: "edit" 
    end
  end
  private 

  def check_location
     unless params[:location_id] && Location.exists?(params[:location_id])
      head :not_found
     end
  end
end
