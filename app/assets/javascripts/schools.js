$(document).ready(function() {
	$('#background_').change(function() {
		$('.info').css('background', $(this).val());
	});
	$('#foreground_').change(function() {
		$('.info').css('color', $(this).val());
	});
	$('button.reset').click(function(e) {
		e.preventDefault();
		$('#foreground_').val($('#foreground_default').val());
		$('#background_').val($('#background_default').val());
		$('ul.search-school .info').css('backgroundColor', $('#background_default').val());
		$('ul.search-school .info').css('color', $('#foreground_default').val());
	});
});