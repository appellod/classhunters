$( document ).ready(function() {
	var autocomplete = (function() {
		var cities = function(element) {
			$(element).autocomplete({
				source: function (request, response) {
					$.getJSON(
						"/autocomplete?location="+request.term,
						function (data) {
							response(data);
						}
					);
				},
				minLength: 3,
			});
		},
		schools = function(element) {
			$(element).autocomplete({
        source: function (request, response) {
					$.getJSON(
						"/autocomplete?school="+request.term,
						function (data) {
							response(data);
						}
					);
				}
      });
		}
		return {
			cities : cities,
			schools : schools
		}
	})();
	autocomplete.cities($('#location'));
	autocomplete.schools($('.search-container #search'));
});
