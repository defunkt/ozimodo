module FeedHelper
  include TypesHelper
  
  # look for feed_content_posttype and give it content, serving its return
  # if it exists.  otherwise just use feed_content
  def serve_content(post)
    method = "feed_content_#{post.post_type}".to_sym
    if self.respond_to? method
      self.send(method, post.content)
    else
      feed_content(post.content)
    end
  end
  
  # try and run the special feed_title_posttype method if it exists.
  # otherwise use feed_title
  def serve_title(post)
    method = "feed_title_#{post.post_type}".to_sym
    if self.respond_to? method
      self.send(method, post)
    else
      feed_title(post)
    end    
  end
  
  # default title handler
  def feed_title(post)
    return strip_textile(post.title) unless post.title.nil?
    strip_textile(post.content)    
  end

  # our default - run this content through redcloth lite
  def feed_content(content)
    rl(content)
  end
  
  # for feed titles, mostly.  strip out the textile markup.
  def strip_textile(x)
    x.gsub(/<.*?>/,'').gsub(/\"(.*?)\":http:\/\/([^ ]*)( )?/,'\1 ')
  end
end
