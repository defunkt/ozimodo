class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts, :order => 'created_at DESC'
  
  # get rid of any tags that aren't attached to a post
  def self.prune_tags
    find(:all, :include => [:posts]).each { |t| t.destroy if t.posts.size == 0 }
  end

  def self.find_most_popular(limit = 5)
    count_col = connection.quote_column_name('count')
    find( :all,
          :select => "tags.id AS id, tags.name AS name, COUNT(*) AS " + count_col,
          :joins  => "JOIN posts_tags ON posts_tags.tag_id = id",
          :group  => "tag_id, id, name",
          :order  => count_col + " desc",
          :limit  => limit )
  end
end
