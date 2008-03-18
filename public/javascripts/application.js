// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var LoginForm = {
  setToPassword: function() {
    $('openid_fields').hide();
    $('password_fields').show();
  },
  
  setToOpenID: function() {
    $('password_fields').hide();
    $('openid_fields').show();
  }
}

document.observe("dom:loaded", function(){
  if (Cookie.get('logged_in')) {
    $$('logged_in').each(Element.show)
    $$('logged_out').each(Element.hide)
  }
})