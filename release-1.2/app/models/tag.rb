class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts, :order => 'created_at DESC'
  
  # get rid of any tags that aren't attached to a post
  def self.prune_tags
    find(:all).each { |t| t.destroy if t.posts.size == 0 }
  end

  def self.find_most_popular(limit = 5)
    find_by_sql("SELECT t.*, count(1) count FROM posts_tags pt 
                 JOIN tags t ON t.id = pt.tag_id GROUP BY tag_id 
                 ORDER BY count DESC LIMIT #{limit}")
  end
end
