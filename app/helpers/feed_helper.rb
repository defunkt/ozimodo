module FeedHelper
  # customized for special types.  needs some work.
  def feed_content(content, type)
    if type == 'image'
      "<img src=\"#{content}\">"
    elsif type =~ /code/
      content
    else
      r content
    end
  end
  
  # for feeds
  def strip_textile(x)
    x.gsub(/<.*?>/,'').gsub(/\"(.*?)\":http:\/\/([^ ]*)( )?/,'\1 ')
  end
end
