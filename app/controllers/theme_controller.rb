class ThemeController < ApplicationController
  caches_page :stylesheets, :javascripts, :images
  
  def stylesheets
    render_theme_item :stylesheets, params[:filename] + '.css', 'text/css'
  end

  def javascripts
    render_theme_item :javascripts, params[:filename] + '.js', 'text/javascript'
  end

  def images
    # Be sure to re-attach the image extension.
    render_theme_item :images, params[:filename] + params[:extension][0] if params[:extension]
  end

  def error
    render :nothing => true, :status => 404
  end

  def static_view_test
  end

private
  
  def render_theme_item(type, file, mime = mime_for(file))
    render :text => "Not Found", :status => 404 and return if file.split(%r{[\\/]}).include?("..")
    send_file theme_dir + "/#{type}/#{file}", :type => mime, :disposition => 'inline', :stream => false
  end
    
  def mime_for(filename)
    case filename.downcase
    when /\.js$/
      'text/javascript'
    when /\.css$/
      'text/css'
    when /\.gif$/
      'image/gif'
    when /(\.jpg|\.jpeg)$/
      'image/jpeg'
    when /\.png$/
      'image/png'
    when /\.swf$/
      'application/x-shockwave-flash'
    else
      'application/binary'
    end
  end  
  
end
