function enableGroupCheck(checker, checkees) {
  $(checker).change(function() {
    if ( $(this).attr('checked') == 'checked' ) 
      $(checkees).attr('checked', 'checked');
    else
      $(checkees).removeAttr('checked');
  });
}

$(function() {
  enableGroupCheck('#all_coordinators', '.notify-coordinators');
  enableGroupCheck('#all_organizers', '.notify-organizers');
  enableGroupCheck('#all_conversation_leaders', '.notify-conversation-leaders');
});
