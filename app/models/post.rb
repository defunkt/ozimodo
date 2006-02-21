class MultiPostFindExpectsArray < StandardError; end

class Post < ActiveRecord::Base
  has_and_belongs_to_many :tags
  belongs_to :user
  
  # Returns a space separated string of all this post's tags
  def tag_names
    self.tags.map { |t| t.name }.join ' '
  end
  
  # take a space separated string or array of tags and sets this post's
  # tags to those, touching their updated_at time as well.
  def tag_names=(tag_names)
    # if we don't get an array or string, abort
    return false unless tag_names.is_a?(Array) or tag_names.is_a?(String)
    
    # get rid of the current tags
    self.tags.clear
    
    # for each tag, set its update_at to now and then add it to the array of 
    # tags associated with this post
    (tag_names.is_a?(String) ? tag_names.split : tag_names).each do |t|
      tag = Tag.find_by_name(t) || Tag.new(:name => t)
      tag.updated_at = Time.now
      self.tags << tag
    end
  end
  
  # get posts with more than one tag.
  # accepts an array or space separated string of tag names
  def self.find_by_tags(tags)
    # if it's a space separated string, break it up
    tags = tags.is_a?(String) ? tags.split : tags
    
    # die if we didn't get an array
    raise MultiPostFindExpectsArray unless tags.is_a?(Array)
    
    # get all the posts containing all the tags in our list
    tags.inject(Tag.find_by_name(tags.shift).posts) do |posts, tag|
      posts = posts & Tag.find_by_name(tag).posts
    end
  end
  
  # get rid of any tags which are not associated with any posts
  def after_save
    Tag.prune_tags
  end
end
