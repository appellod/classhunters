var maps = (function() {
  var map;

  return {
    /**
     * Initializes the #map-canvas element with given parameters.
     * @param lat The latitude
     * @param lon The longitude
     */
    initialize: function(lat, lon) {
      screenWidth = document.documentElement.clientWidth;
      if(screenWidth > 767) {
        var sw = new google.maps.LatLng(lat-0.2, lon-0.2);
        var ne = new google.maps.LatLng(lat+0.2, lon+0.2);
        bounds = new google.maps.LatLngBounds (sw, ne);
        mapOptions = {};
        $('#map-canvas').css('height', '500px');
      } else {
        var sw = new google.maps.LatLng(lat-0.1, lon-0.1);
        var ne = new google.maps.LatLng(lat+0.1, lon+0.1);
        bounds = new google.maps.LatLngBounds (sw, ne);
        document.querySelector("#map-canvas").style.height = '200px';
        var mapOptions = {
          disableDefaultUI: true,
          mapTypeControl: false,
          draggable: false, 
          zoomControl: false, 
          scrollwheel: false, 
          disableDoubleClickZoom: true
        };
      }
      map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
      map.fitBounds(bounds);
      this.marker(lat, lon);
    },

    /**
     * Initializes the #map-canvas element with given parameters.
     * @param lat The latitude
     * @param lon The longitude
     */
    initializeWithBounds: function(min_lat, min_lon, max_lat, max_lon) {
      screenWidth = document.documentElement.clientWidth;
      var sw = new google.maps.LatLng(min_lat, min_lon);
      var ne = new google.maps.LatLng(max_lat, max_lon);
      bounds = new google.maps.LatLngBounds (sw, ne);
      if(screenWidth > 767) {
        mapOptions = {};
        $('#map-canvas').css('height', '500px');
      } else {
        $('#map-canvas').css('height', '200px');
        var mapOptions = {
          disableDefaultUI: true,
          mapTypeControl: false,
          draggable: false, 
          zoomControl: false, 
          scrollwheel: false, 
          disableDoubleClickZoom: true
        };
      }
      map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
      map.fitBounds(bounds);
    },

    /**
     * Places a marker on #map-canvas.
     * @param lat The latitude
     * @param lon The longitude
     * @return The generated marker
     */
    marker: function(lat, lon) {
      var marker = new google.maps.Marker({
          position: new google.maps.LatLng(lat, lon),
          map: map,
      });
      return marker;
    },

    /**
     * Places a marker on #map-canvas. Includes an InfoWindow.
     * @param lat The latitude
     * @param lon The longitude
     * @param school String containing the school's name
     * @param id The id of the school
     * @return The generated marker
     */
    markerWithInfo: function(lat, lon, school, address, id) {
      var marker = new google.maps.Marker({
          position: new google.maps.LatLng(lat, lon),
          map: map,
      });
      var infowindow = new google.maps.InfoWindow({
        content: '<a href="schools/'+id+'"><strong>'+school+'</strong><br>'+address+'</a>'
      });
      google.maps.event.addListener(marker, 'click', function() {
        infowindow.open(map,marker);
      });
      return marker;
    },
  };
})();