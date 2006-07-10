require_dependency 'lib/ozimodo/cookie_auth'

class AdminController < ApplicationController
  include Ozimodo::CookieAuth      # login stuff
  session :on

  before_filter :authorize,        # run the authorize method before we execute
                :except => :login  # any methods (except login) to see if the user
                                   # is actually logged in or not

  before_filter :admin_user_only, :only => [ :users, :rename_user, :delete_user, :create_user ]
 
                                   
  layout "admin/layout"   # admin layout

  helper :tumble, ThemeHelper
  
  # app/models/cache_sweeper.rb's after_save method is invoked if a Post
  # or Tag is saved within any of these methods.  it then clears the appropriate
  # caches.
  cache_sweeper :cache_sweeper, :only => [ :new, :edit, :delete, :rename_tag, :delete_tag,
                                           :delete_user, :rename_user ]
  
  #
  # post management
  #
  
  # we do this a lot.  hrm.
  def index
    list
    render :action => 'list'
  end
  
  # new and edit just wrap to the same method
  def new() save_post end
  def edit() save_post end

  # this method handles creation of new posts and editing of existing posts
  def save_post
    if params[:id] && request.get?
      # want to edit a specific post -- go for it
      @post = Post.find(params[:id])
      @tags = @post.tag_names
      render :action => :new
      
    elsif !params[:id] && request.get?
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
      post.user_id ||= current_user[:id]
      
      # reset all the tag names attached to those submitted
      post.tag_names = params[:tags]
      
      # if this is a yaml post type, grab the params we need, yamlize them, 
      # then set them as the content
      type = params[:post][:post_type]
      post.content = params[:yaml][type].to_yaml if TYPES[type]
      
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
      @post = Post.find(params[:id], :include => [:tags, :user])
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
    CacheSweeper.sweep
    flash[:notice] = "Cache killed."
    redirect_to :back
  end

  def method_missing(m, *args)
    # check if it's an ajax method
    if self.respond_to?(return_method = "#{m}_return")
      return unless request.post? && logged_in?

      post = Post.find(params[:post_id])

      # ajax_edit_title => title
      property = m.to_s.split('_')[2..-1].join('_')

      post.send("#{property}=", self.instance_eval("params[:post_#{property}]"))

      post.save

      self.send(return_method, post)
    else
      raise NoMethodError, m.to_s
    end
  end

  def ajax_edit_title_return(post)
    render :text => post.title.blank? ? "empty-title" : post.title
  end

  def ajax_edit_tag_names_return(post)
    render :text => unless post.tag_names.empty?
                      post.tag_names.split.map { |t| 
                        '<a href="' << url_for({:controller => 'tumble', :action => 'tag', :tag => t}) << %[" class="tag_link">#{t}</a>]
                      }.join(' ')
                    else
                      'empty-tags'
                    end
  end

  def ajax_edit_content_return(post)
    post.yaml_content_to_hash!
    render :partial => "post", :locals => { :post => post }
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
      render :text => tag.name
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
  # crazy calls to mother base
  #
  
  # tries to see if this version of ozimodo is up to date
  def up_to_date
    @version = begin
      # libraries we need
      require 'net/http'
      require 'uri'
      # try to grab the most recent version from the ozimodo site
      host = URI.parse(VERSION_CHECK[:domain]).host
      version = Net::HTTP.start(host, VERSION_CHECK[:port]) do |http|
        http.get(VERSION_CHECK[:page]).body.chomp
      end
      # don't accept anything except x.x(.x[.x])
      return false unless version =~ /^\d{1}\.\d{1}(\.\d){0,2}$/
      # still here, return what we got
      version
    rescue
      # something broke, return false
      false
    end
  end
  
  #
  # user handling
  #
  
  # see if the poor user is authorized
  def authorize 
    redirect_to :controller => 'admin', :action => 'login' unless logged_in?
  end  

  # certain actions only the big man can perform
  def admin_user_only
    redirect_to :controller => 'admin', :action => 'password' unless is_admin_user?
  end

  # the big man
  def is_admin_user?
    (logged_in? && current_user[:id] == User::ADMIN_USER_ID)
  end
  
  # try to login, obviously
  def login
    if request.post?
      @user = User.new(params[:user])
      
      # login check is built into the user model
      logged_in_user = @user.try_to_login

      if logged_in_user
        set_logged_in(logged_in_user, params[:remember_me])
        redirect_to :action => 'list'
      else
        # hax.
        flash[:notice] = 'Username or password incorrect.'
      end

    elsif logged_in?
      # user's already logged in
      redirect_to :action => 'list'
    else
      @user = User.new
    end
  end

  def logout
    set_logged_out
    flash[:notice]    = "Logged out."

    # if they got here from a page other than the admin section, send them back
    ref = request.env['HTTP_REFERER']
    redirect_to ((ref =~ /admin/ || nil) ? { :action => :login } : :back)
  end

  # user list
  def users
    @users = User.find(:all, :order => 'id ASC')
  end
  
  # ajaxly rename a user
  def rename_user
    if request.post?
      user = User.find(params[:user_id])
      user.name = params[:user_name]
      user.save
      render :text => user.name
    end
  end
  
  # up and delete a user
  def delete_user
    user_id = params[:id]
    user = User.find(user_id)

    flash[:notice] = begin
                       user.destroy
                       Post.chown_posts(user_id,User::ADMIN_USER_ID)
                       "User deleted."
                     rescue CantDestroyAdminUser
                       "Can't delete admin user :("
                     end

    redirect_to :action => :users
  end

  # add a new user
  def create_user
    if request.post?
      @user = User.new(params[:user])
      flash[:notice] = case true
                       when !User.password_long_enough?(params[:password][:new])
                         "You gotta make your password longer than five letters... come on."
                       when !User.passwords_match?(params[:password][:new], params[:password][:confirm])
                         "Passwords don't match."
                       end

      return flash[:notice] if flash[:notice]

      @user.password = params[:password][:new]

      if @user.save
        flash[:notice] = "User #{@user.name} created."
        redirect_to :action => 'users'
      else
        flash[:error] = "Error creating user."
      end
    end
  end

  # change your password
  def password
    if params[:id] && is_admin_user?
      @user_id = params[:id].to_i
    elsif params[:id] && !is_admin_user?
      flash[:notice] = "Permission denied.  Must be admin user."
      redirect_to :action => 'users'
    else
      @user_id = current_user[:id]
    end

    if request.post?
      # grab our lovely user
      user = User.find(@user_id)
      
      # see if there's anything wrong with the submitted passwords
      flash[:error] = case true
                      when !User.password_long_enough?(params[:password][:new])
                        "You gotta make your password longer than five letters... come on."
                      when !User.passwords_match?(params[:password][:new], params[:password][:confirm])
                        "Passwords don't match."
                      end

      if params[:password][:old] && User.hash_password(params[:password][:old]) != user.hashed_password
        flash[:error] = "Old password is wrong, sorry." 
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
