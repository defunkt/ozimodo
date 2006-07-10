ActionController::Routing::Routes.draw do |map|
  # theme stuffs
  map.connect 'stylesheets/theme/:filename', :controller => 'theme', :action => 'stylesheets'
  map.connect 'javascripts/theme/:filename', :controller => 'theme', :action => 'javascripts'
  map.connect 'images/theme/:filename', :controller => 'theme', :action => 'images'
  
  # pretty-fy the feed urls
  map.connect 'feed/atom.xml', :controller => 'feed', :action => 'atom'
  map.connect 'feed/rss.xml', :controller => 'feed', :action => 'rss'

  # pagination
  map.connect 'page/:page', :controller => 'tumble', :action => 'list'
  
  # our admin stuffs
  map.connect 'admin', :controller => 'admin', :action => 'list'
  map.connect 'admin/:action', :controller => 'admin'
  
  # show posts by date
  map.connect ':year/:month/:day', :controller => 'tumble', 
    :action => 'list_by_date', :year => /\d{4}/, :month => /\d{1,2}/, 
    :day => /\d{1,2}/

  # show posts by month
  map.connect ':year/:month', :controller => 'tumble', :action => 'list_by_date', 
                              :year => /\d{4}/, :month => /\d{1,2}/
  
  # show posts by type 
  map.connect 'type/:type', :controller => 'tumble', :action => 'list_by_post_type'
        
  # default
  map.connect '', :controller => 'tumble', :action => 'list'
        
  # show a single post
  map.connect ':id', :controller => 'tumble', :action => 'show', :id => /\d+/
  
  # show a tag
  map.connect ':tag', :controller => 'tumble', :action => 'tag', 
                      :tag => /[A-Za-z0-9+ ]+/

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
