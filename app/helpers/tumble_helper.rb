module TumbleHelper
  # try and grab the partial for this post type.  if it doesn't exist, grab the
  # default partial.  re-raise any actionview errors we're not interested in.
  def oz_render_post_type(post)
    begin
      render :partial => "#{TUMBLE['component']}/tumble/types/" + post.post_type, :locals => { :content => post.content }
    rescue ActionView::ActionViewError => e
      if e.to_s =~ /No rhtml/
        render :partial => "#{TUMBLE['component']}/tumble/types/post", :locals => { :content => post.content }
      else
        raise e
      end
    end 
  end
  
  # clean date
  def oz_clean_date(date)
    sprintf "%d/%02d/%02d", date.year, date.month, date.day 
  end
  
  # the 5 most recent tags
  def oz_recent_tags(separator = ' . ')
    return_cache(:recent_tags) do
      tags = Tag.find(:all, :order => "updated_at DESC", :limit => 5)
      recent = ''
      tags.reverse_each do |t|
        recent << link_to(t.name, :controller => 'tumble', :action => 'tag', 
                                  :tag => t.name) + separator
      end
      recent.chomp(separator)
    end
  end
  
  # display all the tags
  def oz_all_tags
    tags = @params[:tag].split(' ') if @params[:tag]
    return_cache(:all_tags, tags) do
      tags = Tag.find(:all, :order => 'name ASC')
      all  = String.new
      tags.each { |t| all << add_tag_link(t.name) + link_to(t.name, 
                  :controller => 'tumble', :action => 'tag', :tag => t.name) + ' ' }
      all
    end 
  end
  
  # the current tag
  def oz_current_tag(default = 'tumble')
    if @error_msg
      "error"
    elsif @params[:tag]
      @params[:tag].gsub(' ','+')
    else
      default
    end
  end
  
  # return a list of posts
  def oz_show_list
    list_block = lambda do
      output = String.new
      for post in @posts
        output << render(:partial => 'post', :locals => { :post => post })
      end if @posts
      return output unless output.empty?
      %[<div id="error-box">I tried to find what you're looking for really hard.
      No matches, though.  Sorry.</div>]
    end
    if @params[:tag]
      tags = @params[:tag].split(' ')
      return_cache(:list_tags, tags) { list_block.call }
    elsif @params[:year] and @params[:month] and @params[:day]
      datestring = "#{@params[:year]}-#{@params[:month]}-#{@params[:day]}"
      return_cache("show_date_#{datestring}") { list_block.call }
    else
      return_cache(:list_posts) { list_block.call } 
    end
  end
  
  # return the post  
  def oz_show_post
    return_cache(@params[:id]) { output = render(:partial => 'post', :locals => { :post => @post }) }
  end
  
  # the relative date
  def oz_relative_date(date = Date.today)
    date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
    days = (date - Date.today).to_i
    case 
      when (days >= 0 and days < 1)     then 'today'
      when (days >= 1 and days < 2)     then 'tomorrow' 
      when (days >= -1 and days < 0)    then 'yesterday' 
      when (days.abs < 60 and days > 0) then "in #{days} days" 
      when (days.abs < 60 and days < 0) then "#{days.abs} days ago"
      when days.abs < 182               then date.strftime('%A, %B %e') 
      else                                   date.strftime('%A, %B %e, %Y')
    end
  end
  
  # if we're looking at a tag, give the option to add (or remove) another tag
  def tag_link(t)
    %[<a href="#{t}" class="tag-link">#{t}</a>]
  end
  
  # add a + or - in front of tags if we're looking at a tag's listing
  def add_tag_link(tag)
    if @params[:tag] and !@params[:tag].split.select { |x| x =~ /^#{tag}$/ }.empty?
      link = @params[:tag].split
      link = link.reject { |x| x =~ /^#{tag}$/ } * '+' unless link.size == 1
      link = '/' if link.size == 1
      %[<a href="#{link}" class="remove-tag">-</a>]
    elsif @params[:tag]
      %[<a href="#{@params[:tag].gsub(' ','+')}+#{tag}" class="add-tag">+</a>]
    else
      ""
    end
  end
  
  # fetch the value of our cached fragment, or write it
  def return_cache(id, tags = nil, &block)
    controller.return_cache(id, tags, &block)
  end
  
  # is caching on or off?
  def caching?; self.caching?; end
  def self.caching?
    ActionController::Base.perform_caching
  end
end