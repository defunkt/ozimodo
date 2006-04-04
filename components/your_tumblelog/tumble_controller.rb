class YourTumblelog::TumbleController < ApplicationController
  uses_component_template_root  # know where our templates are
  helper :tumble, :types, :your_tumble
  layout TUMBLE['component'] + "/tumble/layout"
  
  # show a list of posts -- by date, tag, or the main page
  def list
    @page = params[:page]
    @posts, @post_pages = params[:posts], params[:post_pages]
  end
  
  # show a single post
  def show    
    @post = params[:post]
  end  

  # error method, for redirecting to our hand rolled 404 page
  # with a custom error message
  def error(x = nil)
    x ||= params[:error_msg]
    @error_msg = x unless x.nil?
    self.action_name = :error
    render :action => 'error'
  end
  
end
