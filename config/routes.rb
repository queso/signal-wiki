ActionController::Routing::Routes.draw do |map|
  map.resources :flags


  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session
  map.resource :site, :member => {:expire_cache => :get, :mark_all_private => :get}
  map.resources :users 
  map.resources :pages, :member => {:revision => :get, :rollback => :get, :lock => :get}, :collection => {:search => :get}
  map.resources :attachments

  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.connect 'menus/:action', :controller => 'menus'
  
   
  map.wiki_page '/:id', :controller => "pages", :action => "show"
  map.root :controller => "pages", :action => "show", :id => "home"

end
