# Here is a good place to add your microplugins.
# All controllers inherit from this one.
class ApplicationController < ActionController::Base
  attr_accessor :cache  # we locally cache fragments in a hash after grabbing
                        # them from Rails' cache
  #                        
  # note that app/models/cache_sweeper.rb oversees when and how cached 
  # data is purged.
  #

  # check to see if we already have a cached version of whatever we're looking
  # to grab.
  def check_cache(id, tags = nil)
    # if caching is off, we don't have a cached version.  simple enough.
    return false if perform_caching == false or session[:user_id]
    
    # create the cache instance variable if it's not here
    @cache ||= Hash.new
    
    # convert the id to a symbol if it's not an int, otherwise leave it alone.
    # if the id is a symbol it's probably something like ':list_tags' or 
    # ':list_posts'
    id = id.to_sym unless id.to_i > 0
    
    # now that we have a good id, see if we already did this check recently
    # by looking for the existance of @cache[id]
    return @cache[id] if @cache[id]
    
    # figure out the unique cache identifier for this tasty nugget
    cache_id_hash = build_cache_hash(id, tags)
    
    # set our cached info into the cache instance variable, using the symbol/int
    # id as the key.
    @cache[id] = read_fragment(cache_id_hash)
    
    # if what we got 'twas false, say so.
    return false if @cache[id] == nil || @cache[id] == false
    
    # all clear!
    true
  end
  
  # will check to see if a particular cached item exists and return it.
  # if the item does not exist, will execute the attached block and cache
  # the results, returning them as well.
  # this is called from helper functions, but you might call it from in here.
  # who knows.
  def return_cache(id, tags = nil, &block)
    # execute and return the block if caching is off or the user is logged in.
    # we don't show cached info to the administrator.  she can always log out.
    return(yield block) if perform_caching == false or session[:user_id]
    
    # check to see if the cached item already exists.  if it doesn't, set it.
    if check_cache(id, tags) == false
      # figure out the unique cache identifier for this tasty nugget
      cache_id_hash = build_cache_hash(id, tags)
      
      # save the block's return
      data_to_cache = yield block
      write_fragment(cache_id_hash, data_to_cache)
      
      # save the cached info in our cache instance variablec
      @cache[id] = data_to_cache
    end
    @cache[id].to_s
  end
  
  
  # build a hash to identify a cached fragment with. we keep everything in the 
  # tumble/cache namespace (except feeds)
  def build_cache_hash(id, tags = nil)
    cache_id_hash = { :controller => 'tumble', :action => 'cache', :id => id }
    
    # if we got tags, include those in our hash identifier
    cache_id_hash.merge!({ :tags => tags * ' ' }) unless tags.nil?
    
    # return the finished product
    cache_id_hash
  end
end