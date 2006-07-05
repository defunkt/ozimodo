class StupidIndicexes < ActiveRecord::Migration
  def self.up
    remove_index :posts, :id
    remove_index :tags, :id  
    remove_index :users, :id
  end

  def self.down
    add_index :posts, :id, :unique
    add_index :tags, :id, :unique    
    add_index :users, :id, :unique
  end
end
