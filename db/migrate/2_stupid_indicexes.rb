class StupidIndicexes < ActiveRecord::Migration
  def self.up
    remove_index :posts, :id, :unique
    remove_index :tags, :id, :unique    
    remove_index :users, :id, :unique
  end

  def self.down
    add_index :posts, :id, :unique
    add_index :tags, :id, :unique    
    add_index :users, :id, :unique
  end
end
