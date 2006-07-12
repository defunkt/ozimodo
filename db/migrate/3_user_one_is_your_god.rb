class UserOneIsYourGod < ActiveRecord::Migration
  def self.up
    change_column :posts, :user_id, :integer, :default => 1
  end

  def self.down
    raise "Migrateion UserOneIsYourGod Not Reversible!"
  end
end
