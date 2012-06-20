$(function() {
  sort("#sortable");
});
function sort(sortable) {
  $(sortable).sortable( { 
    handle: ".handle",
    update : function () { 
      $.ajax({
        type: 'post',
        data: $(sortable).sortable('serialize'),
        dataType: 'script',
        complete: function(request){
          $(sortable).effect('highlight');
        },
        url: '/settings/profile_fields/sort'})
    }
  });
  $(sortable).disableSelection();
}
