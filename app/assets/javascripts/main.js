jQuery(document).ready(function($){
  //if you change this breakpoint in the style.css file (or _layout.scss if you use SASS), don't forget to update this value as well
  var MQL = 1170;

  //primary navigation slide-in effect
  if($(window).width() > MQL) {
    var headerHeight = $('.cd-header').height();
    $(window).on('scroll',
    {
          previousTop: 0
      }, 
      function () {
        var currentTop = $(window).scrollTop();
        //check if user is scrolling up
        if (currentTop < this.previousTop ) {
          //if scrolling up...
          if (currentTop > 0 && $('.cd-header').hasClass('is-fixed')) {
            $('.cd-header').addClass('is-visible');
          } else {
            $('.cd-header').removeClass('is-visible is-fixed');
          }
        } else {
          //if scrolling down...
          $('.cd-header').removeClass('is-visible');
          if( currentTop > headerHeight && !$('.cd-header').hasClass('is-fixed')) $('.cd-header').addClass('is-fixed');
        }
        this.previousTop = currentTop;
    });
  }

  //open/close primary navigation
  $('.cd-primary-nav-trigger').on('click', function(){
    $('.cd-menu-icon').toggleClass('is-clicked'); 
    $('.cd-header').toggleClass('menu-is-open');
    
    //in firefox transitions break when parent overflow is changed, so we need to wait for the end of the trasition to give the body an overflow hidden
    if( $('.cd-primary-nav').hasClass('is-visible') ) {
      $('.cd-primary-nav').removeClass('is-visible').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',function(){
        $('body').removeClass('overflow-hidden');
      });
    } else {
      $('.cd-primary-nav').addClass('is-visible').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',function(){
        $('body').addClass('overflow-hidden');
      }); 
    }
  });
  //open/close primary navigation
  $('.cd-second-nav-trigger').on('click', function(){
    $('.cd-menu-icon_2').toggleClass('is-clicked'); 
    $('.cd-header').toggleClass('menu-is-open');
    
    //in firefox transitions break when parent overflow is changed, so we need to wait for the end of the trasition to give the body an overflow hidden
    if( $('.cd-second-nav').hasClass('is-visible') ) {
      $('.cd-second-nav').removeClass('is-visible').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',function(){
        $('body').removeClass('overflow-hidden');
      });
    } else {
      $('.cd-second-nav').addClass('is-visible').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',function(){
        $('body').addClass('overflow-hidden');
      }); 
    }
  });
  $(function() {
    $('ul.submenu').hide();
    $('ul.cd-primary-nav  > li, ul.submenu > li').hover(function () {
    if ($('> ul.submenu',this).length > 0) {
        $('> ul.submenu',this).stop().slideDown('slow');
    }
    },function () {
      if ($('> ul.submenu',this).length > 0) {
        $('> ul.submenu',this).stop().slideUp('slow');
      }
    });
  });
});