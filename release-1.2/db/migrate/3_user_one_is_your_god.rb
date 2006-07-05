class UserOneIsYourGod < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE posts MODIFY COLUMN user_id INT(11) DEFAULT 1"
  end

  def self.down
    execute "ALTER TABLE posts MODIFY COLUMN user_id INT(11) DEFAULT NULL"
  end
end
