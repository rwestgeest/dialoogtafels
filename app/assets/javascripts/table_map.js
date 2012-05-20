
function TablesMap(city, sites) {
  var map = new google.maps.Map(
    document.getElementById("map_canvas"),
    {
      zoom : 16,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });

  var geocoder = new google.maps.Geocoder();

  geocoder.geocode({ 'address' : city + ',NL' }, function(results, status) {
    if (status != google.maps.GeocoderStatus.OK) { return; }
    map.setCenter(results[0].geometry.location);
  });

  if (sites.length < 1) { 
    return; 
  }
  var infoWindow = new google.maps.InfoWindow();

  var bounds = new google.maps.LatLngBounds(map.getCenter(), map.getCenter());
  $.each(sites, function(index, site) {
    var location = new google.maps.LatLng(site.location.lattitude, site.location.longitude);
    var marker = new google.maps.Marker({
      position: location,
      map: map,
      icon: '/images/table-icon.png',
      title: site.location.name
    });

    bounds = bounds.extend(location);

    google.maps.event.addListener(marker, 'click', function() {
      infoWindow.setContent(site.content);
      infoWindow.open(map, marker);
    });
  });

  var listener = google.maps.event.addListener(map, "idle", function() {
    map.setCenter(bounds.getCenter());
    map.fitBounds(bounds);
    google.maps.event.removeListener(listener);
  });
}

function AddressMap(elementIdPrefix, initialLocation) {
  var location = initialLocation;

  var latlng = new google.maps.LatLng(52.085055,5.11819);

  if (location.lattitude && location.longitude) {
    latlng = new google.maps.LatLng(location.lattitude, location.longitude);
  }

  var map = new google.maps.Map(
    document.getElementById(elementIdPrefix + "_map_canvas"),
    { zoom: 14,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });

  var geocoder = new google.maps.Geocoder();

  var marker = new google.maps.Marker({
    position: latlng,
    map: map
  });

  var moveMarkerToAddress = function () {
    geocoder.geocode({ 'address' : getAddress() }, function(results, status) {
      if (status != google.maps.GeocoderStatus.OK) { return; }
      setLocation(results[0].geometry.location);
    });
  }

  var setLocation = function(location) {
      marker.setPosition(location);
      map.setCenter(location, 16);
      $( '#' + elementIdPrefix + "_lattitude").val(location.lat());
      $( '#' + elementIdPrefix + "_longitude").val(location.lng());
  }

  var getAddress = function () {
    return location.address + ',' + location.postalCode + ',' + location.city + ',NL';
  }

  if (location.lattitude == 0 && location.longitude == 0) {
    moveMarkerToAddress();
  }

  this.draggable = function() {
    google.maps.event.addListener(marker, 'dragend', function(event) {
      moveMarkerToLocation(event.latLng);
    });
    marker.setDraggable(true);
    return this;
  }

  var moveMarkerToLocation = function (location) {
    marker.setPosition(location);
    $("#" + elementIdPrefix + "_lattitude").val(location.lat());
    $("#" + elementIdPrefix + "_longitude").val(location.lng());
  }

  this.setAddress = function (newAddress) {
    if (location.address == newAddress) { return; }
    location.address = newAddress;
    moveMarkerToAddress();
  }

  this.setPostalCode = function (newPostalCode) {
    if (location.postalCode == newPostalCode) { return; }
    location.postalCode = newPostalCode;
    moveMarkerToAddress();
  }

  this.setCity = function (newCity) {
    if (location.city == newCity) { return; }
    location.city = newCity;
    moveMarkerToAddress();
  }
}

function editableMap(elementIdPrefix) {
  $(document).ready(function() {
    map = new AddressMap(elementIdPrefix, {
      lattitude : $('#' + elementIdPrefix + '_lattitude').val(),
      longitude : $('#' + elementIdPrefix + '_longitude').val(),
      address   : $('#' + elementIdPrefix + '_address').val(),
      postalCode: $('#' + elementIdPrefix + '_postal_code').val(),
      city      : $('#' + elementIdPrefix + '_city').val()
    });

    $('#' + elementIdPrefix + '_address').blur(function() {
      map.setAddress($('#' + elementIdPrefix + '_address').val());
    })
    $('#' + elementIdPrefix + '_postal_code').blur(function() {
      map.setPostalCode($('#' + elementIdPrefix + '_postal_code').val());
    })
    $('#' + elementIdPrefix + '_city').blur(function() {
      map.setCity($('#' + elementIdPrefix + '_city').val());
    })
  });
}

function staticMap(city, sites) {
  $(document).ready(function() {
    new TablesMap(city, sites)
  });
}

