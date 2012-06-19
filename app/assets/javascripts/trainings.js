$(function() {
  $('#training_start_date').change(function() {
    $('#training_end_date').val( $(this).val() );
  });
  $("#training_start_date").datepicker({
      changeMonth: true,
      changeYear:true

  });
  $("#training_end_date").datepicker({
      changeMonth: true,
      changeYear:true,
  });

});

function enable_training_expansion() {
  $('.expandable-training-element').click( function() {
    $($(this).attr('data-element')).toggle(500) ;
  });
}
$(function(){
  enable_training_expansion();
});
