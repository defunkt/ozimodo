class ApiController < ApplicationController
  include Ozimodo::CookieAuth      # login's for our API friends too

  before_filter :authorize,                        # run the authorize method before  
                :only => [ :post, :edit, :delete ] # we do anything that modifies stuff

  def list
    respond_with Post.find(:all, :limit => 20, :order => 'created_at DESC').map(&:attributes)
  end

  def show
    begin
      if params[:id].to_i > 0
        respond_with Post.find(params[:id], :include => [:tags, :user])
      else
        respond_with :error => "Give me an ID"
      end
    rescue ActiveRecord::RecordNotFound
      respond_with :error => "Post not found with an ID of #{params[:id]}"
    end
  end

  def types
    respond_with TYPES.map { |k, v| { k => (v ? v.keys : 'content') } }
  end

  def login
    user = User.new(:name => params[:username], :password => params[:password])
    logged_in_user = user.try_to_login
    set_logged_in(logged_in_user) if logged_in_user
    render :nothing => true
  end

  def method_missing(meth, *args)
    if TYPES.keys.include?(meth.to_s)
      return unless authorize
      return respond_with(:error => "Missing post parameters.") unless params[:post].is_a?(Hash)

      if params[:post][:tags]
        params[:post][:tag_names] = params[:post][:tags]
        params[:post].delete(:tags)
      end
      
      post = Post.new(params[:post].merge(:post_type => meth.to_s, :user_id => current_user[:id]))

      if post.save
        respond_with "Post saved with id of #{post.id}"
      else
        respond_with :error => "Posting error."
      end
    else
      respond_with :error => "I don't understand #{meth}."
    end
  end

private
  # wrap up our response idiom
  def respond_with(var)
    respond_to do |type|
      type.yaml { render :text => var.to_yaml }
      type.xml  { render :text => var.to_xml }
      type.text { render :text => var.inspect }
    end
  end

  # admin_controller's authorize not friendly for api people
  def authorize
    return true if logged_in?

    if params[:username] && params[:password]
      if user = User.new(:name => params[:username], :password => params[:password]).try_to_login
        @cookie_data = { :name => user.name, :id => user.id }
        return true
      end
    end

    respond_with :error => "You need to login to do that."
    false
  end
end