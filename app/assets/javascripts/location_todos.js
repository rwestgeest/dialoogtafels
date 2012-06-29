function enable_location_todo_button() {
    $("#new_location_todo_button").click(function() {
      $.ajax({
          url: '/settings/location_todos',
          data: { location_todo: { name: $("#new_location_todo_input").val()} },
          type: 'post'
      });
      return false;
    });
}
function enable_ok_button_for_location_todo_update(todo_id) {
    $('#update_location_todo_button_' + todo_id).click(function() {
      $.ajax({
          url: '/settings/location_todos/'+todo_id,
          data: { location_todo: { name: $("#update_location_todo_input_"+todo_id).val()} },
          type: 'put'
      });
      return false;
    });
    $("#update_location_todo_input_"+todo_id).focus();
}

$(function() {
  enable_location_todo_button();
});

