class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts, :order => 'created_at DESC'
  
  # get rid of any tags that aren't attached to a post
  def self.prune_tags
    find(:all).each { |t| t.destroy if t.posts.size == 0 }
  end
end
