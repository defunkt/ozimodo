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
  def is_cached?(id, tags = nil)
    # really just a wrapper to get_cache
    get_cache(id, tags)
  end
  
  # set a cache key directly
  def set_cache(id, data, tags = nil)
    # instantiate our @cache object if it doesn't exist and get a key for it
    @cache ||= {}    
    key = cache_obj_key(id, tags)
    
    # build a key for this cache fragment
    cache_id_hash = build_cache_hash(id, tags)
    
    # save to @cache object for quick reference later
    @cache[key] = data
    
    # write to the cache
    write_fragment(cache_id_hash, data)
  end
  
  # more inuitive method
  def set_cache_with_tags(id, tags, data)
    set_cache(id, data, tags)
  end
  
  # get a cache key directly
  def get_cache(id, tags = nil)
    # if caching is off, we don't have a cached version.  simple enough.
    return false if perform_caching == false or session[:user_id]    
        
    # create @cache hash and get a key for it
    @cache ||= {}    
    key = cache_obj_key(id, tags)
    
    # see if we already did this check recently
    # by looking for the existence of @cache[id]
    return @cache[key] if @cache[key]    
    
    # read from the cache, save it into our @cache object for quick reference
    cache_id_hash = build_cache_hash(id, tags)
    @cache[key]   = read_fragment(cache_id_hash)
  end
  
  # create a key for our @cache object
  def cache_obj_key(id, tags)
    # always alphabetical, cut down on cache keys
    tags.sort! if !tags.nil? and tags.is_a? Array
    (id.to_s + (tags ? tags * '+' : '')).to_sym
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
    unless is_cached? id, tags      
      # save the block's return
      data_to_cache = yield block
      
      set_cache_with_tags(id, tags, data_to_cache)
    end
    get_cache(id, tags)
  end
  
  
  # build a hash to identify a cached fragment with. we keep everything in the 
  # tumble/cache namespace (except feeds)
  def build_cache_hash(id, tags = nil)
    # ids must be symbols or ints
    id = id.to_sym unless id.to_i > 0    
    
    # get the hash
    cache_id_hash = { :controller => 'tumble', :action => 'cache', :id => id }
    
    # if we got tags, include those in our hash identifier
    # alphabetize tags to keep number of redundant keys down
    unless tags.nil?
      tags.sort! if tags.is_a? Array
      cache_id_hash.merge!({ :tags => tags * ' ' })
    end
    
    # return the finished product
    cache_id_hash
  end
end