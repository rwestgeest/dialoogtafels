function enable_conversation_button() {
    $("#new_conversation_button").click(function() {
      $.ajax({
          url: '/conversations/new',
          data: { location: location_id },
          type: 'get'
      });
      return false;
    });
}
function enable_ok_button_for_conversation_update(todo_id) {
    $('#update_conversation_button_' + todo_id).click(function() {
      $.ajax({
          url: '/organizing_city/conversations/'+todo_id,
          data: { conversation: { name: $("#update_conversation_input_"+todo_id).val()} },
          type: 'put'
      });
      return false;
    });
    $("#update_conversation_input_"+todo_id).focus();
}

$(function() {
  enable_conversation_button();
});

