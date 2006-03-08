ActionController::Routing::Routes.draw do |map|
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  # pretty-fy the feed urls
  map.connect 'feed/atom.xml', :controller => 'feed', :action => 'atom'
  map.connect 'feed/rss.xml', :controller => 'feed', :action => 'rss'

  # component styles
  map.connect 'styles/:style', :controller => 'tumble', :action => 'styles'  
  
  # pagination
  map.connect 'page/:page', :controller => 'tumble', :action => 'list'
  
  # our admin stuffs
  map.connect 'admin', :controller => 'admin', :action => 'list'
  map.connect 'admin/:action', :controller => 'admin', :action => :action
  
  # show posts by date
  map.connect ':year/:month/:day', :controller => 'tumble', 
    :action => 'show_for_date', :year => /\d{4}/, :month => /\d{1,2}/, 
    :day => /\d{1,2}/

  # show posts by month
  map.connect ':year/:month', :controller => 'tumble', 
    :action => 'show_for_month', :year => /\d{4}/, :month => /\d{1,2}/
        
  # default
  map.connect '', :controller => 'tumble', :action => 'list'
        
  # show a single post
  map.connect ':id', :controller => 'tumble', :action => 'show', 
                     :id => /\d+/
  
  # show a tag
  map.connect ':tag', :controller => 'tumble', :action => 'tag', 
                      :tag => /[A-Za-z0-9+]+/

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
