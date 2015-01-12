function resizeHomePage() {
  screenHeight = document.documentElement.clientHeight;
  screenWidth = document.documentElement.clientWidth;
  if(screenWidth > 767) {
  	menuHeight = document.querySelector('.menu').clientHeight;
		topHeight = document.querySelector('.top-banner').clientHeight;
  	elementHeight = screenHeight - menuHeight - topHeight;
    
    caption_size = screenWidth / 20;
    input_size = screenWidth / 50;
    input_width = screenWidth / 2;
    input_height = screenHeight / 12;
    if (caption_size > 70) {
    	caption_size = 70;
    }
    if (input_size > 30) {
    	input_size = 30;
    }
    if (input_width > 700) {
    	input_width = 700;
    }
    if (input_height > 75) {
    	input_height = 75;
    }
    perks_height = document.querySelector('.home-perks').clientHeight + 5;
    if(screenHeight <= 650) {
      perks_height = 175;
      $('.home-perks').css('font-size', '12px');
      $('.home-contact').css('font-size', '12px');
    } else {
      perks_height = 217;
    }
    $('.home-form').css('height', elementHeight - perks_height + 'px');
    $('.home-form .container-fluid').css('height', elementHeight - perks_height - 5 + 'px');
    $('.home-form h1').css('font-size', caption_size + 'px');
    $('.home-form .group').css('width', input_width + 100 + 'px');
    $('.home-form .input-group').css('width', input_width + 'px');
    $('.home-form .input-group input').css('height', input_height + 'px');
    $('.home-form .input-group button').css('height', input_height+ 'px');
    $('.home-form .input-group input').css('font-size', input_size + 'px');
    $('.home-form .input-group button').css('font-size', input_size * .85 + 'px');
    if(screenWidth / elementHeight > 1.727910238429173) {
    	$('.home-form').css('backgroundSize', '100% auto');
    } else {
    	$('.home-form').css('backgroundSize', '100% auto');
    }
  } else {
  	menuHeight = document.querySelector('.mobile-menu .header').clientHeight;
  	elementHeight = screenHeight - menuHeight;
  	if(screenWidth / elementHeight > 1.727910238429173) {
  		//wide
	  	$('.home-form').css('height', elementHeight + 'px');
	  	$('.home-form .container-fluid').css('height', elementHeight + 'px');
    	$('.home-form').css('backgroundSize', '100% auto');
    	$('.home-form').css('backgroundPosition', '0px 0px');
    } else {
    	//tall
    	$('.home-form').css('height', elementHeight + 'px');
	  	$('.home-form .container-fluid').css('height', elementHeight + 'px');
    	$('.home-form').css('backgroundSize', 'auto 100%');
    	$('.home-form').css('backgroundPosition', '50% 0px');
    }
  }
}

function setContentHeight() {
  screenHeight = document.documentElement.clientHeight;
  menuHeight = document.querySelector('.menu').clientHeight;
  topHeight = document.querySelector('.top-banner').clientHeight;
  elementHeight = screenHeight - topHeight - menuHeight - 50;
  if(document.querySelector('.content') != null) {
    if (document.querySelector('.content').clientHeight < elementHeight) {
      $('.content').css('height', elementHeight + 'px');
    }
  }
}

/**
 * Checks URL to determine which menu item to set active.
 */
function setActiveMenuItem() {
	url = document.URL;
  if(url.indexOf('users') >= 0) {
    setLiToActive('Account');
  } else if(url.indexOf('courses') >= 0) {
    setLiToActive('Courses');
	} else if(url.indexOf('schools') >= 0) {
		setLiToActive('Schools');
	} else if(url.indexOf('about') >= 0) {
		setLiToActive('About');
	} else if(url.indexOf('contact') >= 0) {
		setLiToActive('Contact');
	} else if(url.indexOf('about') >= 0) {
		setLiToActive('About');
	} else if(url.indexOf('signin') >= 0) {
		setLiToActive('Sign In');
	} else if(url.split('/')[3].length == 0) {
		setLiToActive('Home');
	}
}

/**
 * Iterates through all li elements in .navbar to find item
 * specified by str. If match is found, sets li to active.
 * @param str String indicating the text of li to set active.
 */
function setLiToActive(str) {
	$('.navbar li').each(function(){
    if($(this).find('a').html() == str) {
    	$(this).addClass('active');
    }
  });
}

/**
 * Finds the coordinates of the user and sends them in an AJAX request to the 
 * site_controller's location action.
 */
function locate() {
  navigator.geolocation.getCurrentPosition(function(position) {
    var url = "/location";
    var data = 'latitude=' + position.coords.latitude + '&longitude=' + position.coords.longitude;
    $.ajax({
      type: "POST",
      url: url,
      data: data,
      success: function(data) {
      }
    });
  });
}

/**
 * Checks to see if current scroll position is greater than the 
 * top desktop banner. If so, sets menu to fixed. If at top of page,
 * sets the menu back to relative.
 */
function fixMenuOnScroll() {
  screenWidth = document.documentElement.clientWidth;
  if(screenWidth > 767) {
    scroll_y = $(document).scrollTop();
    banner_height = document.querySelector('.top-banner').clientHeight;
    fixed = false;
    if(scroll_y >= banner_height && !fixed) {
      $('.menu').css('position', 'fixed');
      fixed = true;
    } else {
      $('.menu').css('position', 'relative');
      fixed = false;
    }
  }
}

$(document).ready(function() {
  $(function() {
    $("#menu").mmenu();
  });
  //setContentHeight();
	setActiveMenuItem();
	if(document.title == 'Classhunters | Find A Class Near You') {
	  resizeHomePage();
	  $(window).on('resize', function() {
	  	resizeHomePage();
	  });
	}
  $('input').focus(function() {
  	placeholder = $(this).attr('placeholder');
    alignment = $(this).css('text-align');
  	$(this).attr('placeholder', '');
    $(this).css('textAlign', 'left');
  });
  $('input').focusout(function() {
  	$(this).attr('placeholder', placeholder);
    $(this).css('textAlign', alignment);
  });
  $(window).scroll(function() {
    //fixMenuOnScroll();
  });
  $( ".search-container #search" ).autocomplete({
    source: 'schools/autocomplete'
  });
  $('.expand').click(function() {
    $('.expand-container').toggle();
    if ($('.expand').html().indexOf('+') >= 0) {
      $('.expand').html($('.expand').html().replace('+', '-'));
    } else {
      $('.expand').html($('.expand').html().replace('-', '+'));
    }
  });
});
