class GetYourTumbleOn < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.column :user_id,    :int
      t.column :title,      :string, :limit => 100
      t.column :post_type,  :string, :limit => 15
      t.column :content,    :text
      t.column :created_at, :datetime
    end
    add_index :posts, :id, :unique
    
    create_table(:posts_tags, :id => false) do |t|
      t.column :post_id, :int
      t.column :tag_id,  :int
    end
    add_index :posts_tags, [:post_id, :tag_id]
    
    create_table :tags do |t|
      t.column :name,       :string,  :limit => 25
      t.column :updated_at, :datetime
    end
    add_index :tags, :id, :unique
    
    create_table :users do |t|
      t.column :name,            :string, :limit => 20
      t.column :hashed_password, :string, :limit => 40
    end
    add_index :users, :id, :unique
    
    User.new( :name => "admin", :password => 'changeme' ).save
    
    Post.new( :title => "first post!", :post_type => "post", 
              :content => %[Hello, world.  I'm tumblin'!
              Check out 
              <a href="http://ozimodo.rubyforge.org/configure.html">http://ozimodo.rubyforge.org/configure.html</a>
              for info on how to totally customize your tumblelog.],
              :user_id => 1 ).save
  end

  def self.down
    %w[posts posts_tags tags users].each { |t| drop_table t.to_sym }
  end
end
