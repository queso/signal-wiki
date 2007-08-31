ActionController::Routing::Routes.draw do |map|
  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session

  
  map.resources :pages, :member => {:revision => :get, :rollback => :get}
  map.resources :users 

  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.connect '', :controller => "pages"
  map.wiki_page '/:id', :controller => "pages", :action => "show"
  

end
