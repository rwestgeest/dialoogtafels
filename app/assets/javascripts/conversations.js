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
      changeYear:true,
  });
}
$(function(){
  $( "#dialog-form" ).dialog({
			autoOpen: false,
			height: 300,
			width: 350,
      title: "Move stuff",
			modal: true,
			buttons: {
				"Create an account" : function() {
           $(this).form('submit')
						$( this ).dialog( "close" );
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			},
			close: function() {
			}
		});

  $('.move_conversation_leader').click(function(){
    $( "#dialog-form" ).dialog( "open" );
  });
  $('.move_participant').click(function(){
    $( "#dialog-form" ).dialog( "open" );
  });
});
