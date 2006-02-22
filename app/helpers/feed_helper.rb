module FeedHelper
  # if there is no title, serve the content if we can
  def serve_title(title, content)
    return strip_textile(title) unless title.empty?
    content
  end

  # customized for special types.  needs some work.
  def feed_content(content, type)
    if type == 'image'
      "<img src=\"#{content}\">"
    elsif type =~ /code/
      content
    else
      rl(content)
    end
  end
  
  # for feeds
  def strip_textile(x)
    x.gsub(/<.*?>/,'').gsub(/\"(.*?)\":http:\/\/([^ ]*)( )?/,'\1 ')
  end
end
