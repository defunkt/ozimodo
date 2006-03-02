class TumbleController < ApplicationController
    
  # show all the posts for a specific date
  def show_for_date
    # build a date string
    datestring = "#{params[:year]}-#{params[:month]}-#{params[:day]}"
    cached = is_cached? "show_date_#{datestring}"
    begin
      # try and find posts for this day in history - add a wildcard
      posts = Post.find(:all, :conditions => ["created_at LIKE ?", datestring + '%'], 
                        :order => 'created_at DESC') unless cached
      params = @params
      params.merge!(:posts => posts) unless cached
      render_tumblelog_component(:list, params)
    rescue ActiveRecord::RecordNotFound
      error "No posts found for that date."
    end
  end

  # list all the posts for the index page
  # do nothing if this info is already cached
  # behavior is configured in config/tumble.yml
  def list
    # get the status of the cache so we know whether we should do db queries
    cached = is_cached? 'list_posts'
    
    # how many posts/days to show?
    limit = TUMBLE['limit']
    
    if TUMBLE['sort'] == 'date'
      # show by day -- find posts within limit days ago from most recent post
      start = Post.find(:first, :order => 'created_at DESC').created_at - (60*60*24 * limit-1)
      params = { :conditions => ["created_at >= ?", start.strftime("%Y-%m-%d 00:00:00")] }
      
    else
      # show by post -- find last limit posts
      params = { :limit => limit }
    end unless cached # don't hit the db or do any figurin' if it's cached
    
    posts = Post.find(:all, params.merge(:order => 'created_at DESC')) unless cached # same here.
    render_component_list(posts)
  end
  
  # display all the posts associated with a tag
  def tag
    tags = params[:tag].split(' ')
    
    # if more than one tag is specified, get the posts containing all the
    # passed tags.  otherwise get all the posts with just the one tag.
    # don't do any processing if this information is already cached.
    begin
      if tags.is_a? Array
        posts = Post.find_by_tags(tags)
      else
        posts = Tag.find_by_name(tags).posts
      end unless is_cached? :list_tags, tags # gates of madness.
      
      render_component_list( :posts => posts, :tag => params[:tag] )
      
    rescue NoMethodError
      error "Tag not found."
    end
  end

  # show a post based on its id, or redirect if we got here through hackery.
  # again, don't grab any info if we've already cached this momma.
  def show
    begin
      if params[:id]
        post = Post.find(params[:id]) unless is_cached? params[:id]
        render_component_show(post)
      else
        redirect_to :action => 'list'
      end
    rescue ActiveRecord::RecordNotFound
      error "Post not found."
    end
  end
  
  # display a stylesheet
  def styles
    # get a cache key for this style
    cache_key = "style/#{params[:style]}"
    
    # check to see if the style is already cached
    # if so, grab it
    css = get_cache(cache_key) if is_cached? cache_key
    
    # now grab the time we cached the file
    time_cached = get_cache(cache_key + '/stamp')
    
    # what is the name of this file?
    style_file = "#{RAILS_ROOT}/components/#{TUMBLE['component']}/tumble/styles/#{params[:style]}"
    
    # if the cache is older than the modified time of the css file, expire it
    css = nil if time_cached and perform_caching == true and File.new(style_file).mtime > time_cached
    
    # if it's not cached and the file exists, grab it and cache it
    # also timestamp the cache
    if css.nil? and File.exists? style_file 
      css = render_to_string :file => style_file 
      set_cache cache_key, css
      set_cache cache_key + '/stamp', Time.now
    end
    
    # still no css?  404.
    unless css
      error 404
    else
      # display
      headers['Content-Type'] = 'text/css'
      render :text => css, :layout => false          
    end
  end
  
  # send unknown actions down the pipe
  def method_missing(meth, *args)
    render_tumblelog_component(meth, @params)
  end

  # error method, for redirecting to our hand rolled 404 page
  # with a custom error message
  def error(x = nil)
    render_tumblelog_component( 'error', { :error_msg => x } )
  end
  
  private
  
  # shortcut to calling our component 'list' action
  def render_component_list(params = nil)
    params = { :posts => params } unless params.nil? or params.is_a? Hash
    render_tumblelog_component( 'list', params )
  end
  
  # shortcut to calling our component 'show' action
  def render_component_show(params = nil)
    params = { :post => params } unless params.nil? or params.is_a? Hash
    render_tumblelog_component( 'show', params )
  end
  
  # in case something changes, or we need to spiff up the params
  def render_tumblelog_component(action, params)
    params ||= Hash.new
    params.merge( :id => @params[:id] )
    render_component  :controller => "#{TUMBLE['component']}/tumble",
                      :action => action.to_s, :params => params
  end
  
end
