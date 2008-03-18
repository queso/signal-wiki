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
    insert_flag();
    insert_nav();
  } else {
    $$('#nav .logged_in').each(Element.hide);
  }
  
})

function insert_flag() {
  if (flag = $('flag')) {
    url = "flaggable_type=" + flag.title.gsub("_", "&flaggable_id=");
    new Ajax.Updater('flag', '/flags/new?'+url, { asynchronous: true, method: 'get' })
  }
}
function insert_nav() {
  $$('#nav .logged_in').each(Element.show);
  $$('#nav .logged_out').each(Element.hide);
  login = Cookie.get('logged_in').gsub(/\W/m, ""); // hack attack
  $('login').innerHTML = login;
}