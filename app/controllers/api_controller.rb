class ApiController < ApplicationController
  include Ozimodo::CookieAuth      # login's for our API friends too

  before_filter :authorize,                        # run the authorize method before  
                :only => [ :post, :edit, :delete ] # we do anything that modifies stuff

  def list
    respond_with hasherize_post(Post.find(:all, :limit => 10, :order => 'created_at DESC', :include => [:tags, :user]))
  end

  def show
    begin
      if params[:id].to_i > 0
        respond_with hasherize_post(Post.find(params[:id], :include => [:tags, :user]))
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

  def commands
    commands  = self.methods - %w[login method_missing]
    commands -= ApplicationController.instance_methods
    commands -= Ozimodo::CookieAuth.instance_methods
    commands += TYPES.keys
    respond_with commands.sort
  end

  def login
    user = User.new(:name => params[:username], :password => params[:password])
    logged_in_user = user.try_to_login
    set_logged_in(logged_in_user) if logged_in_user
    render :nothing => true
  end

  def method_missing(meth, *args)
    if TYPES.keys.include?(meth.to_s)
      return respond_with(:error => "You must login.") unless authorize
      return respond_with(:error => "Missing post parameters.") unless params[:post].is_a?(Hash)

      # fix stupid legacy mistake of mine
      params[:post][:tag_names] = params[:post][:tags] if params[:post][:tags]

      # special case for 'link' type
      if meth.to_s == 'link' && params[:post][:url] && params[:post][:text]
        params[:post][:content] = %["#{params[:post][:text]}":#{params[:post][:url]}]
      end

      # we only want good post parameters
      post_params = {}
      %w[content tag_names title].each { |key| post_params[key] = (params[:post][key] || '') }
      post_params.merge!(:post_type => meth.to_s, :user_id => current_user[:id])

      post = Post.new(post_params)

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
    var.stringify_keys! if var.is_a? Hash

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

  # don't want to include user password and just need tags as a string
  def hasherize_post(post)
    if post.is_a? Array
      post.map { |p| hasherize_post(p) }
    else
      { post.id => post.attributes.merge({ 'tags' => post.tags.map(&:name).join(' '), 'user' => post.user.name }) }
    end
  end
end
