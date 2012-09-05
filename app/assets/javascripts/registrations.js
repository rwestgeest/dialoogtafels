function enable_registration_togglers() {
  $('span.register-link').click(function() {
      $($(this).attr('data-toggle')).toggle();
    });
}
$(function() {
  enable_registration_togglers();
  $('#people_filter').change(function(){
    $('#filter_form').submit();
  });
});

