document.addEventListener('DOMContentLoaded', function(){

  hljs.configure({tabReplace: '  '});

  Array.prototype.forEach.call(document.querySelectorAll('.highlight pre code'), function(e){
    hljs.highlightBlock(e);
  });

  var link_to_top = '<a href="#document-top" title="Back to top">&#8593</a>';

  Array.prototype.forEach.call(document.querySelectorAll('h2, h3, h4, h5, h6'), function(e){
    e.appendChild(link_to_top);
  });

})
