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
  
  # show all the posts for a specific month
  def show_for_month
    # build a date string
    datestring = "#{params[:year]}-#{params[:month]}"
    cached = is_cached? "show_month_#{datestring}"
    begin
      # try and find posts for this day in history - add a wildcard
      posts = Post.find(:all, :conditions => ["created_at LIKE ?", datestring + '%'], 
                        :order => 'created_at DESC') unless cached
      params = @params
      params.merge!(:posts => posts) unless cached
      render_tumblelog_component(:list, params)
    rescue ActiveRecord::RecordNotFound
      error "No posts found for that month."
    end
  end

  # list all the posts for the index page
  # do nothing if this info is already cached
  # behavior is configured in config/tumble.yml
  def list
    # get the status of the cache so we know whether we should do db queries
    key = if @params[:page] and @params[:page].to_i > 1
      %[list_posts_page_#{@params[:page]}]
    else
      'list_posts'
    end.to_sym
    cached = is_cached? key
  
    post_pages, posts = paginate :posts, :order => 'created_at DESC', 
                                 :per_page => TUMBLE['limit'] unless cached 
    render_component_list(:posts => posts, :post_pages => post_pages, :page => @params[:page])
  end
  
  
  # display all the posts associated with a tag
  def tag
    tags = params[:tag].split(' ')
    
    # if more than one tag is specified, get the posts containing all the
    # passed tags.  otherwise get all the posts with just the one tag.
    # don't do any processing if this information is already cached.
    begin
      posts = tags.is_a?(Array) ? Post.find_by_tags(tags) : Tag.find_by_name(tags).posts unless is_cached? :list_tags, tags      
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
    style_file = "#{RAILS_ROOT}/components/#{TUMBLE['component']}/tumble/styles/#{params[:style]}" 
    unless File.exists? style_file
      error 404
    else
      # display
      headers['Content-Type'] = 'text/css'
      render :file => style_file
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
    params ||= {}
    params.merge( :id => @params[:id] )
    render_component  :controller => "#{TUMBLE['component']}/tumble",
                      :action => action.to_s, :params => params
  end
  
end
