module City::LocationsHelper
  include TodosHelper
  def todo_link location_todo
    return selected_text( location_todo.name ) if location_todo == @selected_todo
    return raw link_to location_todo.name, city_locations_path(:todo => location_todo.id)
  end
end
