module FeedHelper
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
    title = strip_textile(
      if self.respond_to? method
        self.send(method, post)
      else
        feed_title(post)
      end
    )
    title.size > 30 ? "#{title[0..30].strip}..." : title
  end
  
  # default title handler
  def feed_title(post)
    return post.title unless post.title.nil? or post.title.blank?
    post.content
  end

  # our default - run this content through redcloth lite
  def feed_content(content)
    rl(content)
  end
end
