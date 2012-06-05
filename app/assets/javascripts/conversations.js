function enable_start_and_end_date(minutes) {
  $('#conversation_start_date').change(function() {
    $('#conversation_end_date').val( $(this).val() );
  });
  $("#conversation_start_date").datepicker({
      changeMonth: true,
      changeYear:true
  });
  $("#conversation_end_date").datepicker({
      changeMonth: true,
      changeYear:true
  });
}

