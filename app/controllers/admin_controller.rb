class AdminController < ApplicationController
  before_filter :authorize,        # run the authorize method before we execute
                :except => :login  # any methods (except login) to see if the user
                                   # is actually logged in or not
                                   
  layout "admin"   # admin layout
  helper :tumble, :types # load up our helpers
  
  # app/models/cache_sweeper.rb's after_save method is invoked if a Post
  # or Tag is saved within any of these methods.  it then clears the appropriate
  # caches.
  cache_sweeper :cache_sweeper, :only => [ :new, :edit, :delete, :kill_cache, 
                                           :ajax_edit_title, :ajax_edit_content,
                                           :ajax_edit_tag_names ]
  
  
  #
  # post management
  #
  
  # we do this a lot.  hrm.
  def index
    list
    render :action => 'list'
  end
  
  # new and edit just wrap to the same method
  def new; save_post; end
  def edit; save_post; end

  # this method handles creation of new posts and editing of existing posts
  def save_post
    if params[:id] and request.get?
      # want to edit a specific post -- go for it
      @post = Post.find(params[:id])
      @tags = @post.tag_names
      render :action => :new
      
    elsif !params[:id] and request.get?
      # want to create a new post -- go for it
      @post = Post.new
      @tags = nil
      render :action => :new
            
    elsif request.post?
      # post request means something big is going to happen.
      # set post variable to the post in question if we're editing, otherwise
      # open a new object
      post = params[:id] ? Post.find(params[:id]) : Post.new
      
      # reset all of post's attributes, replacing them with those submitted
      # from the form
      post.attributes = params[:post]
      
      # if post has no user_id set, give it the id of the logged in user
      post.user_id ||= session[:user_id]
      
      # reset all the tag names attached to those submitted
      post.tag_names = params[:tags]
      
      # if this is a yaml post type, grab the params we need, yamlize them, 
      # then set them as the content
      type = params[:post][:post_type]
      post.content = params[:yaml][type].to_yaml if YAML_TYPES[type]
      
      # save the post - if it fails, send the user back from whence she came
      if post.save
        flash[:notice] = 'Post was successfully saved.'
        redirect_to :action => 'show', :id => post.id
      else
        flash[:notice] = "There was an error saving your post."
        render :action => self.action_name
      end
    else
      # i don't know how you'd ever get here but i don't know a lot of things
      redirect_to :action => :list
    end
  end

  # be polite and show a post
  def show
    if params[:id]
      @post = Post.find(params[:id])
      @tags = @post.tag_names
    else
      redirect_to :action => :list
    end
  end

  # ooo, pagination.
  def list
    @post_pages, @posts = paginate :post, {:per_page => 20, :order_by => 'id DESC'}
  end

  # grab the post and destroy it.  simple enough.
  def delete
    post = Post.find(params[:id])
    post.destroy
    flash[:notice] = 'Post deleted.'
    redirect_to :action => :list
  end
  
  # could be better.  grab the last post and save it, forcing a refresh of
  # most of our cache.  
  def kill_cache
    Post.find(:first, :order => "created_at DESC").save
    expire_fragment /show_date/    
    flash[:notice] = "Cache killed."
    redirect_to request.env['HTTP_REFERER']
  end
  
  #
  # ajax editing of posts
  #
  
  # a hash of methods we want to define... ajax_edit_#{key} will be the 
  # method name.  the attribute we care about will be params[:post_#{key}].
  # we will set it to post.#{key}.  the values in the hash are the code we will
  # run upon success, what we return.
  ajax_methods = { 
    :title => 'render_text post.title.blank? ? "empty-title" : post.title', 
    :tag_names => %q[render_text(if post.tag_names.size>0;post.tag_names.split.map { |t| 
                    "<a href=\"#{t}\">#{t}</a>"}.join(' '); else;'empty-tags';end)],
    :content => %q[post.yaml_content_to_hash!; render :partial => "post", :locals => {:post=>post}]
  }
  
  # define our methods three
  ajax_methods.each do |m, r|
    define_method("ajax_edit_#{m}".to_sym) do
      if request.post?
        post = Post.find(params[:post_id])
        post.send("#{m}=", self.instance_eval("params[:post_#{m}]"))
        post.save
        self.instance_eval r
      end
    end
  end
  
  #
  # tag management
  #
  
  # ajaxly rename the tag
  def rename_tag
    if request.post?
      tag = Tag.find(params[:tag_id])
      tag.name = params[:tag_name]
      tag.save
      render_text tag.name
    end
  end
  
  # up and delete a tag
  def delete_tag
    tag = Tag.find(params[:id])
    tag.destroy
    flash[:notice] = 'Tag deleted.'
    redirect_to :action => :list_tags
  end

  # up and paginate a tag
  def list_tags
    @tag_pages, @tags = paginate :tag, {:per_page => 10, :order_by => 'id DESC'}
  end
  
  #
  # user handling
  #
  
  # see if the poor user is authorized
  def authorize
    unless session[:user_id]
      redirect_to :controller => 'admin', :action => 'login'
    end
  end  
  
  # try to login, obviously
  def login
    if request.post?
      @user = User.new(params[:user])
      # login check is built into the user model
      logged_in_user = @user.try_to_login
      if logged_in_user
        # the mere existence of :user_id in the session hash means a user
        # is logged in 
        session[:user_id] = logged_in_user.id
        redirect_to :action => 'list'
      else
        # hax.
        flash[:notice] = 'Username or password incorrect.'
      end
    elsif session[:user_id]
      # user's already logged in
      redirect_to :action => 'list'
    else
      @user = User.new
    end
  end

  def logout
    # important to get rid of the session variable
    session[:user_id] = nil
    flash[:notice]    = "Logged out."
    # if they got here from a page other than the admin section, send them back
    ref = request.env['HTTP_REFERER']
    redirect_to ref =~ /admin/ ? {:action => :login} : ref
  end

  # change your password
  def password
    if request.post?
      # grab our lovely user
      user = User.find(session[:user_id])
      
      # see if there's anything wrong with the submitted passwords
      flash[:error] = case true
        when User.hash_password(params[:password][:old]) != user.hashed_password
          "Old password is wrong, sorry."
        when params[:password][:new].length < 6
          "You gotta make your password longer than six letters... come one."
        when params[:password][:new] != params[:password][:confirm]
          "Passwords don't match."
      end
      
      # end this transaction if we got an error
      return flash[:error] unless flash[:error].nil?
      
      # okay, change the password.
      user.password = params[:password][:new]
      user.save
      
      flash[:notice] = "Password changed."
    end
  end
  
end