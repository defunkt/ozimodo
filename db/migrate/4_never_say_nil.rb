class NeverSayNil < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE posts MODIFY COLUMN title varchar(255) NOT NULL DEFAULT ''"
    execute "ALTER TABLE posts MODIFY COLUMN content text NOT NULL DEFAULT ''"
  end

  def self.down
    execute "ALTER TABLE posts MODIFY COLUMN title varchar(255) DEFAULT NULL"
    execute "ALTER TABLE posts MODIFY COLUMN content text DEFAULT NULL"
  end
end
