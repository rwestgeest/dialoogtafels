$(function() {
  $('.banner-list .city_banner').click(function() {
    window.location.href = $(this).attr("data-location-url");
  });
});
