require_dependency File.join(RAILS_ROOT, 'lib', 'ozimodo', 'cookie_auth')
require_dependency File.join(THEME_DIR, 'theme_helper')

class TumbleController < ApplicationController      
  include Ozimodo::CookieAuth
  session :off

  caches_page :list, :tag, :show
  layout 'tumble/layout.rhtml'

  helper ThemeHelper 

  # list all the posts
  def list(options = Hash.new)
    options.merge!({ :order => 'created_at DESC', :include => [:tags, :user], :per_page => TUMBLE['limit'] })

    @post_pages, @posts = paginate :posts, options
    render :action => 'list'
  end

  # list by date - its own method so we can do pagination right
  def list_by_date
    datestring = "#{params[:year]}-#{params[:month]}"
    datestring << "-#{params[:day]}" if params[:day]
    list :conditions => ['created_at LIKE ?', datestring + '%']
  end
  
  # list by post type - its own method so we can do pagination right
  def list_by_post_type
    list :conditions => ['post_type = ?', params[:type]]
  end

  # display all the posts associated with a tag
  def tag
    tags = params[:tag].split(' ')
    
    # if more than one tag is specified, get the posts containing all the
    # passed tags.  otherwise get all the posts with just the one tag.
    if tags.size > 1
      @posts = Post.find_by_tags(tags)
    else
      post_ids = Tag.find_by_name(tags, :include => [:posts], :order => 'posts.created_at DESC').posts.map(&:id)
      @post_pages, @posts = paginate :posts, :include => [:tags, :user], :conditions => post_ids, :per_page => TUMBLE['limit'],
                                             :order => 'created_at DESC' 
    end

    if @posts.size.nonzero?
      render :action => 'list'
    else
      error "Tag not found."
    end
  end

  # show a post, or redirect if we got here through hackery.
  def show
    begin
      if params[:id]
        @post = Post.find(params[:id], :include => [:tags, :user])
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
    @error_msg = x
    render :action => 'error'
  end
  
  # override template root to your theme's
  def self.template_root
    theme_dir
  end

end
