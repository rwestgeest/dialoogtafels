class City::LocationsController < ApplicationController
  # GET /city/locations
  # GET /city/locations.json
  def index
    @city_locations = Location.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @city_locations }
    end
  end

  # GET /city/locations/1
  # GET /city/locations/1.json
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  # GET /city/locations/new
  # GET /city/locations/new.json
  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @location }
    end
  end

  # GET /city/locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /city/locations
  # POST /city/locations.json
  def create
    @location = Location.new(params[:location])

    respond_to do |format|
      if @location.save
        format.html { redirect_to city_location_path(@location), notice: 'Location was successfully created.' }
        format.json { render json: @location, status: :created, location: @location }
      else
        format.html { render action: "new" }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /city/locations/1
  # PUT /city/locations/1.json
  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to city_location_path(@location), notice: 'Location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /city/locations/1
  # DELETE /city/locations/1.json
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to city_locations_url }
      format.json { head :no_content }
    end
  end
end
