# helpers you put in here will be accessible to your tumblelog and are 
# super portable.  if you're looking for the core ozi helpers, check out
# app/helpers/tumble_helper.rb
module ThemeHelper
  #
  # general theme helpers
  #
  
  # get an array of tag names and generate a comma separated, linked string of tags
  def linked_tags_with_commas(tags, sep = ", ")
    tags.dup.map { |tag|
      tag_link(tag.name)
    }.join(sep)
  end

  def popular_tags
    Tag.find_most_popular(4).map { |t| tag_link(t.name) }.to_sentence
  end

  #
  # ajaxy editing
  #
  def ajaxy_edit(type, post)
    return unless logged_in? && controller.perform_caching == false
    oz_render_theme_partial "ajax/edit_#{type}", { :locals => { :post => post } }
  end
  
  #
  # type helpers
  #
  
  # for titles -- protect irc channel names, specifically
  def t(x)
    return r(x).gsub(/<(\/)?p>/,'') unless x[0,1] == '#'
    x
  end
  
  # RedCloth wrapper -- clean this up if you have redcloth installed for sure
  def r(x, options = [])
    RedCloth.new(x, options).to_html
  end
  
  # RedCloth lite
  def rl(x)
    r(x, [:lite_mode])
  end
  
  # syntax highlight ruby code -- same as redcloth, clean it up
  def rc(x)
    begin
      require 'syntax'
      require 'syntax/convertors/html'
      Syntax::Convertors::HTML.for_syntax("ruby").convert(x)
    rescue
      x
    end
  end
  
  # see if we have dependencies -- feel free to nuke this
  def require_test(file, gem = false)
    begin
      require file unless gem == true
      require_gem file if gem == true
      %[<span style="color: green;">found</span>]
    rescue MissingSourceFile, Gem::LoadError
      %[<span style="color: red;">not found</span>]
    end    
  end
  
  #
  # type specific helper functions for atom and rss feeds!
  #
  # check app/helpers/feed_helper.rb for more info on these
  #
  
  # for the quote type
  def feed_content_quote(content)
    ret = %[&quot;#{content.quote}&quot;]
    ret += " -- #{content.author}" if content.author
    strip_textile ret
  end
  
  # slip an image into a feed
  def feed_content_image(content)
    %[<img src="#{content.src}" alt="#{content.alt}">]
  end
  
  # use the alt if we provided no title
  def feed_title_image(post)
    post.title.blank? ? post.content.alt : post.title
  end

  # just show the code
  def feed_content_code(content)
    content
  end
  
  # quote title - same as the content
  def feed_title_quote(post)
    feed_content_quote(post.content)
  end
  
end
