$(function(){
  hljs.configure({tabReplace: '  '});
  $('.highlight pre code').each(function(i, e){
    hljs.highlightBlock(e);
  });
  var link_to_top = '<a href="#document-top" title="Back to top">&#8593</a>';

  $('h2, h3, h4, h5, h6').each(function(i, e){
    $(e).append(link_to_top);
  });

  $('.conditional-sidebar').prepend('<div class="conditions"></div>');
  $('.conditional-sidebar > div > p:first-child').each(function(i, e){
    var inner_sidebar = $(e).parent();
    var dest = $(e).parent().parent();
    var p = $(e).clone();
    var cls = inner_sidebar.attr('class');
    inner_sidebar.removeClass();
    inner_sidebar.addClass(cls+"-target")
    $(e).remove();
    ($("<div />").addClass(cls).append(p)).appendTo($('.conditions', dest));
  })
  $('.conditional-sidebar .conditions > div:first').addClass('selected');
  $('.conditional-sidebar > div[class$=target]').hide();
  $('.conditional-sidebar > div[class$=target]:first').show();
  $('.conditional-sidebar .conditions > div').click(function(){
    var conditional_sidebar = $(this).parent().parent();
    var target = $("."+$(this).attr('class')+"-target", conditional_sidebar); 
    var targets = $("div[class$='target']", conditional_sidebar);
    $(this).siblings().removeClass('selected');
    $(this).addClass('selected');
    targets.hide();
    console.log(target);
    target.show();
  })
})

