var locate = (function() {

  return {
    byGeocoder: function(str, reload) {
      geocoder = new google.maps.Geocoder();
      geocoder.geocode({ 'address': str }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          var city = '';
          var state = '';
          for(i = 0; i < results[0].address_components.length; i++) {
            if(results[0].address_components[i].types.indexOf('locality') > -1) {
              city = results[0].address_components[i].long_name;
            } else if(results[0].address_components[i].types.indexOf('administrative_area_level_2') > -1 && city.length == 0) {
              city = results[0].address_components[i].long_name;
            } else if(results[0].address_components[i].types.indexOf('administrative_area_level_1') > -1) {
              state = results[0].address_components[i].short_name;
            }
          }
          var latitude = results[0].geometry.location.k;
          var longitude = results[0].geometry.location.D;
          var url = "/location";
          var data = 'latitude=' + latitude + '&longitude=' + longitude + '&city=' + city + '&state=' + state + '&method=coordinates';
          $.ajax({
            type: "POST",
            url: url,
            data: data,
            success: function(data) {
              if(reload){
                window.location.reload();
              }
            }
          });
        }
      });
    },

    byCoordinates: function(latitude, longitude) {
      geocoder = new google.maps.Geocoder();
      geocoder.geocode({ 'address': latitude + ', ' + longitude }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          var city = '';
          var state = '';
          for(i = 0; i < results[0].address_components.length; i++) {
            if(results[0].address_components[i].types.indexOf('locality') > -1) {
              city = results[0].address_components[i].long_name;
            } else if(results[0].address_components[i].types.indexOf('administrative_area_level_2') > -1 && city.length == 0) {
              city = results[0].address_components[i].long_name;
            } else if(results[0].address_components[i].types.indexOf('administrative_area_level_1') > -1) {
              state = results[0].address_components[i].short_name;
            }
          }
          var url = "/location";
          var data = 'latitude=' + latitude + '&longitude=' + longitude + '&city=' + city + '&state=' + state + '&method=coordinates';
          $.ajax({
            type: "POST",
            url: url,
            data: data,
          });
          $(".location-form input").val(city + ', ' + state);
        }
      });
    }
  };
})();