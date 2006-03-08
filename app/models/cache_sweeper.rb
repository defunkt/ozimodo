class CacheSweeper < ActionController::Caching::Sweeper
  observe Post, Tag

  # this method is invoked is a Post or Tag is saved in certain methods we
  # registered within app/controllers/admin/post_controller.rb
  def after_save(record)
    if record.is_a?(Post)
      # we're saving a new post.  get its id.
      id = record.id
      
      # clear out tag list caches
      expire_fragment /all_tags/
      expire_fragment /list_tags/
      expire_fragment /popular_tags/      
      
      # clear out the cache for that post's day
      date = record.created_at
      date_id = sprintf("show_date_%d-%02d-%02d", date.year, date.month, date.day )
      expire_fragment :controller => '/tumble', :action => 'cache', :id => date_id
      
      # clear out the cache for that post's month
      date_id = sprintf("show_month_%d-%02d", date.year, date.month )
      expire_fragment :controller => '/tumble', :action => 'cache', :id => date_id
      
      # expire the cache for this posts page
      expire_fragment :controller => '/tumble', :action => 'cache', :id => id    
      
      # grab the 20 most recent posts (those appearing on the front page)
      # and paint an array of their ids
      rposts = Post.find(:all, :order => 'created_at DESC', :limit => 20).map { |p| p.id }
    
      # if the post we're saving appears on the front page, we need to reset the
      # feed caches as well as the recent_tags cache and the list_posts cache
      if rposts.include?(id)
        expire_page :controller => "/feed", :action => "rss.xml"
        expire_page :controller => "/feed", :action => "atom.xml"
        expire_fragment /list_posts/
        expire_fragment :controller => '/tumble', :action => 'cache', :id => :recent_tags        
      end
    end
  end
end