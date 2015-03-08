var lastHeight = 0;

function resizeHomePage() {
  screenHeight = document.documentElement.clientHeight;
  screenWidth = document.documentElement.clientWidth;
  if(screenWidth > 767) {
  	menuHeight = document.querySelector('.menu').clientHeight;
		topHeight = document.querySelector('.top-banner').clientHeight;
  	elementHeight = screenHeight - menuHeight - topHeight;
    
    caption_size = screenWidth / 22;
    input_size = screenWidth / 52;
    input_width = screenWidth / 2;
    input_height = screenWidth / 18;
    group_padding = screenHeight / 20;
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
    if(screenHeight <= 650) {
      $('.top-banner').css('font-size', '10px');
      $('.home-perks').css('font-size', '10px');
      $('.home-contact').css('font-size', '10px');
      $('.home-contact label').css('font-size', '14px');
      perks_height = 160;
    } else {
      perks_height = 210;
    }
    $('.home-form').css('height', elementHeight - perks_height + 'px');
    $('.home-form .container-fluid').css('height', elementHeight - perks_height - 5 + 'px');
    $('.home-form h1').css('font-size', caption_size + 'px');
    $('.home-form .group').css('width', input_width + 100 + 'px');
    $('.home-form .group').css('padding', group_padding + 'px 0px');
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
    if(Math.abs(elementHeight - lastHeight) > 100) {
      if(screenWidth / elementHeight > 1.727910238429173) {
        //wide
        $('.home-form').css('height', elementHeight + 'px');
        $('.home-form .container-fluid').css('height', elementHeight + 'px');
        $('.home-form .container-fluid').css('background', 'rgba(0,0,0,.8)');
        $('.home-form').css('backgroundSize', '100% auto');
        $('.home-form').css('backgroundPosition', '0px 0px');
        $('.home-form h1').css('font-size', '3.2em');
        $('.home-form h1').html('Find a Class Near You');
        $('.home-form form').css('padding', '0px');
        $('.home-form form').css('border', 'none');
        $('.home-form form').css('background-color', 'transparent');
        $('.home-form form').css('margin-top', '0px');
      } else {
        //tall
        $('.home-form').css('height', elementHeight * .75 + 'px');
        $('.home-form .container-fluid').css('height', elementHeight * .75 + 'px');
        $('.home-form .container-fluid').css('background', 'rgba(0,0,0,0)');
        $('.home-form-mobile').css('backgroundSize', 'auto 100%');
        $('.home-form-mobile').css('backgroundPosition', '50% 0px');
        $('.home-form h1').css('font-size', '3.75em');
        $('.home-form h1').html('Find a Class<br>Near You');
        $('.home-form form').css('height', elementHeight * .75 + 'px');
        $('.home-form form').css('padding', elementHeight / 11 + 'px 0px 35px 0px');
        $('.home-form form').css('border-top', '2px solid #FF5500');
        $('.home-form form').css('border-bottom', '2px solid #FF5500');
        $('.home-form form').css('background-color', 'rgba(0,0,0,.8)');
      }
    }
  	lastHeight = elementHeight;
  }
}

function resizeBackground() {
  if(document.documentElement.clientWidth / document.documentElement.clientHeight > 1.509803921568627) {
    $('body').css('backgroundSize', '100% auto');
  } else {
    $('body').css('backgroundSize', 'auto 100%');
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

function isDescendant(p, c) {
  if(p.indexOf('.')) {
    p = document.getElementsByClassName(p)[0];
  } else {
    p = document.getElementById(p);
  }
  if(c.indexOf('.')) {
    c = document.getElementsByClassName(c)[0];
  } else {
    c = document.getElementById(c);
  }
  var node = c.parentNode;
  while (node != null) {
    if (node == p) {
      return true;
    }
    node = node.parentNode;
  }
  return false;
}

$(document).ready(function() {
  $(function() {
    $("#menu").mmenu();
  });
  $("input").keypress(function(event) {
    if (event.which == 13) {
      event.preventDefault();
      $(this).closest('form').submit();
    }
  });
	setActiveMenuItem();
  resizeBackground();
  $(window).on('resize', function() {
    resizeBackground()
  });
	if(document.title == 'Find A Class Near You | Classhunters') {
	  resizeHomePage();
	  $(window).on('resize', function() {
	  	resizeHomePage();
	  });
	}
  $('.home-form input').focus(function() {
  	placeholder = $(this).attr('placeholder');
  	$(this).attr('placeholder', '');
    $(this).css('textAlign', 'left');
  });
  $('.home-form input').focusout(function() {
  	$(this).attr('placeholder', placeholder);
    if($(this).val() == '') {
      $(this).css('textAlign', 'center');
    }
  });
  $( ".search-container #search" ).autocomplete({
    source: 'schools/autocomplete'
  });
  $('.check-all').click(function() {
    $(this).closest('table').find(':checkbox').prop('checked', true);
  });
  $('.uncheck-all').click(function() {
    $(this).closest('table').find(':checkbox').prop('checked', false);
  });
  bindActionsToSearchResults();
  $(".location-form button").click(function(e) {
    e.preventDefault();
    navigator.geolocation.getCurrentPosition(function(position) {
      locate.byCoordinates(position.coords.latitude, position.coords.longitude);
    });
  });
  $("#school-location-form").submit(function(e) {
    e.preventDefault();
    locate.byGeocoder($('#school-location-form input#location').val(), true);
  });
  $(window).resize(function() {
    resizeSearchHeaders();
    fitTablesToContainer();
  }).resize(); // Trigger resize handler
  $('.days-container tr, .department-container tr').click(function(e) {
    if(!$(e.target).is(':checkbox')){
      var checkbox = $(this).find(':checkbox');
      checkbox.prop("checked", !checkbox.prop("checked"));
    }
  });
  $('form.search_form .submit').click(function(e) {
    $(this).closest('form').submit();
  });
  $('form.search_form').submit(function(e) {
    submitSearchForm($(this), e);
  });
  $('.expand').click(function() {
    $('.expand-container').toggle();
    if ($('.expand').html().indexOf('+') >= 0) {
      $('.expand').html($('.expand').html().replace('+', '-'));
      $(this).addClass('open');
    } else {
      $('.expand').html($('.expand').html().replace('-', '+'));
      $(this).removeClass('open');
    }
  });
});

function fitTablesToContainer() {
  $('table.search-courses').css('width', $('ul.search-school').width());
  $('table.search-courses thead').css('width', $('ul.search-school').width());
  $('table.search-courses tbody').css('width', $('ul.search-school').width());
}

function resizeSearchHeaders() {
  var $table = $('table.search-courses'),
      $bodyCells = $table.find('tbody tr:first').children(),
      colWidth;

  // Get the tbody columns width array
  colWidth = $bodyCells.map(function() {
      return $(this).width();
  }).get();
  
  // Set the width of thead columns
  $table.find('thead tr').children().each(function(i, v) {
      $(v).width(colWidth[i]);
  });
}

function displayCourseInfo(element, id, data_type) {
  if(element.next().attr('class') == "inspect") {
    element.next().slideToggle(200, function() {
      element.next().remove();
    });
  } else {
    $.ajax({
      type: "GET",
      url: '/courses/json',
      data: data_type + '_id=' + id,
      success: function(data) {
        element.after(data.html);
        element.next().toggle();
        element.next().slideToggle(200);
      }
    });
  }
}

function submitSearchForm(element, e) {
  e.preventDefault();
  $('form.search_form input').blur();
  school = '&school_id=' + $('form.search_form').data("id");
  $.ajax({
    url: '/courses/search', 
    type: 'GET', 
    data: $('form.search_form').serialize() + school, 
    success: function(results) {
      $('.results').html(results.results_html);
      if(!$('.expand').length) {
        $('form.search_form').html(results.form_html);
        $('.expand').click(function() {
          $('.expand-container').toggle();
          if ($('.expand').html().indexOf('+') >= 0) {
            $('.expand').html($('.expand').html().replace('+', '-'));
            $(this).addClass('open');
          } else {
            $('.expand').html($('.expand').html().replace('-', '+'));
            $(this).removeClass('open');
          }
        });
      }
      var obj = { Title: document.title, Url: window.location.href.split('?')[0] + '?' + $('form.search_form').serialize() };
      history.pushState(obj, obj.Title, obj.Url);
      bindActionsToSearchResults();
    },
    error: function(e) {
      params = $('form.search_form').serialize();
      if(params.indexOf('semester=') > -1) {
        url_path = '/courses/sessions';
      } else {
        url_path = '/courses';
      }
      window.location.href = url_path + '?' + params;
    }
  });
}

function bindActionsToSearchResults() {
  $("ul.search-school .info").click(function() {
    if ($(this).html().indexOf('+') >= 0) {
      $(this).html($(this).html().replace('+', '-'));
    } else {
      $(this).html($(this).html().replace('-', '+'));
    }
    $(".collapse", $(this).parent()).slideToggle(200);
    $("ul", $(this).parent()).slideToggle(200);
    resizeSearchHeaders();
  });
  $('table.search-courses tr').click(function() {
    data_type = '';
    if($(this).data("course-id") > 0) {
      data_type = 'course';
      id = $(this).data("course-id");
    } else {
      data_type = 'session';
      id = $(this).data("session-id");
    }
    displayCourseInfo($(this), id, data_type);
  });
}

$(document).on('DOMMouseScroll mousewheel', '.scrollable', function(ev) {
    if(Math.abs($(this).css('maxHeight').replace('px', '') - $(this).height()) < 5) {
      var $this = $(this),
          scrollTop = this.scrollTop,
          scrollHeight = this.scrollHeight,
          height = $this.height(),
          delta = (ev.type == 'DOMMouseScroll' ?
              ev.originalEvent.detail * -40 :
              ev.originalEvent.wheelDelta),
          up = delta > 0;

      var prevent = function() {
          ev.stopPropagation();
          ev.preventDefault();
          ev.returnValue = false;
          return false;
      }

      if (!up && -delta > scrollHeight - height - scrollTop) {
          // Scrolling down, but this will take us past the bottom.
          $this.scrollTop(scrollHeight);
          return prevent();
      } else if (up && delta > scrollTop) {
          // Scrolling up, but this will take us past the top.
          $this.scrollTop(0);
          return prevent();
      }
    }
});

//Clearable
$(function($) {
  function tog(v){return v?'addClass':'removeClass';} 
  $(document).on('input', '.clearable', function(){
    $(this)[tog(this.value)]('x');
  }).on('mousemove', '.x', function( e ){
    $(this)[tog(this.offsetWidth-30 < e.clientX-this.getBoundingClientRect().left)]('onX');   
  }).on('click', '.onX', function(){
    $(this).removeClass('x onX').val('').change(); 
  });
  $(".clearable").each(function() {
    if($(this).val().length > 0) {
      $(this).addClass('x');
    }
  });
});

