class ApiController < ApplicationController
  include Ozimodo::CookieAuth      # login's for our API friends too

  # run the authorize method before we do anything that modifies stuff
  before_filter :authorize, :only => [ :post, :edit, :delete, :whoami ] 

  def list
		case params[:id]
		when 'short'
			posts = Post.find(:all, :limit => 30, :order => 'created_at DESC')
			posts = posts.collect {|a| { a.id => a.title, } }
			respond_with posts
    else
			respond_with hasherize_post(Post.find(:all, :limit => 10, :order => 'created_at DESC', :include => [:tags, :user]))
		end
  end

	def help
		@command = params[:id]
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

	def delete
		begin
			if params[:id].to_i > 0
				post = Post.find(params[:id])
				if post.destroy	
					respond_with :text => "all has gone according to plan. you post #{params[:id]} has been removed"
				else
					respond_with :error => "Unable to delete that post"
				end
			else
				respond_with :error => 'Give me and ID'
			end
		rescue ActiveRecord::RecordNotFound
			respond_with :error => "Post not found with and ID of #{params[:id]}"
		end
	end

  def types
    respond_with TYPES.map { |k, v| { k => (v ? v.keys : 'content') } }
  end

  def tags
    # order by most popular.  could do this in sql but i am lazy and ruby is my best friend.
    respond_with Tag.find(:all, :include => :posts).map { |t| { t.name => t.posts.size } }.sort_by { |k| k[k.keys.first] }.reverse
  end

  def posts_with_tag
    respond_with params[:id] ?  hasherize_post(Post.find_by_tag(params[:id])) : { :error => "Please supply a tag" }
  end

  def version
    respond_with :version => OZIMODO_VERSION
  end

  def whoami
    respond_with :user => current_user[:name], :host => request.host, :port => request.port
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
      return unless authorize
      return respond_with(:error => "Missing post parameters.") unless params[:post].is_a?(Hash)

      # fix stupid legacy mistake of mine
      params[:post][:tag_names] = params[:post][:tags] if params[:post][:tags]

      # get this type's parameters
      TYPES[meth.to_s].keys.each do |key|
        params[:post][:content] ||= {}
        params[:post][:content][key] = params[:post][key]
      end if TYPES[meth.to_s]

      # special case for 'link' type
      if meth.to_s == 'link' && params[:post][:url] && params[:post][:text]
        params[:post][:content] = %["#{params[:post][:text]}":#{params[:post][:url]}]
      end

      # get the good post parameters
      post_params = {}
      %w[content tag_names title].each do |key| 
        post_params[key] = (params[:post][key] || '')
      end

      post_params.merge!(:post_type => meth.to_s, :user_id => current_user[:id])

      post = Post.new(post_params)

      if post.save
        respond_with :success => "Post saved with id of #{post.id}"
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
      type.text { render :text => var.to_yaml.sub("---", '').lstrip } # yaml without the --- starter
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
