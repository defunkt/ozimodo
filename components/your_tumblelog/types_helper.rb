#
# where all the helper functions related to your tumble types go.
# 
module TypesHelper
  
  # for titles -- protect irc channel names, specifically
  def t(x)
    return r(x).gsub(/<(\/)?p>/,'') unless x[0,1] == '#'
    x
  end
  
  # RedCloth wrapper -- clean this up if you have redcloth installed for sure
  def r(x)
    begin
      require_gem 'RedCloth'
      RedCloth.new(x).to_html
    rescue
      x
    end
  end
  
  # RedCloth lite
  def rl(x)
    begin
      require_gem 'RedCloth'
      RedCloth.new(x, [:lite_mode]).to_html
    rescue
      x
    end
  end
  
  # syntax highlight ruby code -- same as redcloth, clean it up
  def rc(x)
    begin
      require_gem 'syntax'
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
    ret = %[&quo;#{content.quote}&quo;]
    ret += " -- #{content.author}" if content.author
    ret
  end
  
  # slip an image into a feed
  def feed_content_image(content)
    %[<img src="#{content.src}" alt="#{content.alt}">]
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