 class MultiPostFindExpectsArray < StandardError; end

class Post < ActiveRecord::Base
  has_and_belongs_to_many :tags
  belongs_to :user
  
  # call yamlize_content after we load each record, to translate its content
  # from yaml to a hash (if necessary)
  def after_find() yaml_content_to_hash! end

  def before_save
    content_to_yaml! if content.is_a? Hash
  end
 
  # yamlize in place
  def yaml_content_to_hash!
    self.content = yaml_content_to_hash
  end
  
  # if the post_type of this post says our content is stored as YAML turn it 
  # into a hash.  otherwise just return the content.
  def yaml_content_to_hash
    return self.content unless TYPES[self.post_type]
    # turn the content (yaml) into a hash
    new_content   = YAML.load(self.content) unless self.content.blank?
    new_content ||= {}
    # meta mumbo jumbo to turn content.key into content['key']
    class <<new_content 
      def method_missing(key, *args)
        return nil if !self[key] && !self[key.to_s]
        self[key] || self[key.to_s]
      end
    end
    # commit
    new_content
  end
  
  # yamlize content in place
  def content_to_yaml!
    self.content = content_to_yaml
  end
  
  # return yaml from hash if the content needs to be yaml, otherwise return the 
  # content as it stands
  def content_to_yaml
    (TYPES[self.post_type] ? self.content.to_yaml : self.content)
  end
  
  # returns a space separated string of all this post's tags
  def tag_names
    self.tags.map { |t| t.name }.join(' ')
  end
  
  # take a space separated string or array of tags and sets this post's
  # tags to those, touching their updated_at time as well.
  def tag_names=(tag_names)
    # if we don't get an array or string, abort
    return false unless tag_names.is_a?(Array) || tag_names.is_a?(String)
    
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

  # find all posts with a single tag
  def self.find_by_tag(tag)
    find(:all, :joins => 'JOIN posts_tags pt ON pt.post_id = posts.id', 
         :conditions => ['pt.tag_id = tags.id AND tags.name = ?', tag],
         :include => [:tags, :user], :order => 'created_at DESC')
  end
  
  # get an array of months which have posts.
  def self.archived_months
    sql = 'SELECT DATE_FORMAT(created_at, "%m/%y") month 
           FROM posts GROUP BY month ORDER BY created_at ASC'
    ActiveRecord::Base.connection.select_all(sql).map { |row| row['month'] }
  end

  # chown all posts from one user_id to another
  def self.chown_posts(owner_id, new_owner_id)
    Post.find_by_user_id(owner_id).each do |post|
      post.user_id = new_owner_id
      post.save
    end
  end
  
  # update the updated_at for all the tags we're touching
  def touch_tags
    self.tags.each { |t| t.updated_at = Time.now; t.save }
  end

  # get rid of any tags which are not associated with any posts
  def after_save
    touch_tags
    Tag.prune_tags
  end
end
