module LocationsHelper
  def location_structs(locations)
    result = locations.collect { |location| 
      { :location => location, 
        :content => render(:partial => 'map_location', :locals => {:location => location})
      } 
    }
    raw result.to_json
  end
end
