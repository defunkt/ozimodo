class NeverSayNil < ActiveRecord::Migration
  def self.up
    change_column :posts, :title, :string, :default => ''
    change_column :posts, :content, :text, :default => ''
  end

  def self.down
    puts "Migration NeverSayNil not reversible... not a big deal."
  end
end
