class TumbleController < ApplicationController
    
  # show all the posts for a specific date
  def show_for_date
    # build a date string
    datestring   = "#{params[:year]}-#{params[:month]}-#{params[:day]}"
    cache_status = check_cache("show_date_#{datestring}")
    begin
      # try and find posts for this day in history - add a wildcard
      posts = Post.find(:all, :conditions => ["created_at LIKE ?", datestring + '%'], 
                        :order => 'created_at DESC') unless cache_status == true
      params = @params
      params.merge!(:posts => posts) unless cache_status == true
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
    cache_status = check_cache('list_posts')
    # how many posts/days to show?
    limit = TUMBLE['limit']
    if TUMBLE['show'] == 'by date'
      # show by day -- find posts within limit days ago from most recent post
      start = Post.find(:first, :order => 'created_at DESC').created_at - (limit-1)
      params = { :conditions => ["created_at >= ?", start.strftime("%Y-%m-%d 00:00:00")] }
    else
      # show by post -- find last limit posts
      params = { :limit => limit }
    end unless cache_status == true # don't hit the db or do any figurin' if it's cached
    # don't grab anything if cached
    posts = Post.find(:all, params.merge(:order => 'created_at DESC')) unless cache_status == true # same here.
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
      end unless check_cache(:list_tags, tags) == true # gates of madness.
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
        post = Post.find(params[:id]) unless check_cache(params[:id]) == true
        render_component_show(post)
      else
        redirect_to :action => 'list'
      end
    rescue ActiveRecord::RecordNotFound
      error "Post not found."
    end
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
    render_component  :controller => 'your_tumblelog/tumble',
                      :action => action.to_s, :params => params
  end
  
end
