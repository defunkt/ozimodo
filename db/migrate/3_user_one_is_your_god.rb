class UserOneIsYourGod < ActiveRecord::Migration
  def self.up
    change_column :posts, :user_id, :integer, :default => 1
  end

  def self.down
    puts "Migration UserOneIsYourGod not reversible... not a big deal."
  end
end
