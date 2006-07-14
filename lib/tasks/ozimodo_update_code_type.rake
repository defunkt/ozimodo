namespace :ozimodo do
  desc "Update all 'ruby_code' post types to new 'code' post type."
  task :update_code_type => :environment do
    ruby_code_posts = Post.find(:all, :conditions => ['post_type = ?', 'ruby_code'])
    unless ruby_code_posts.blank?
      count = ruby_code_posts.size
      ruby_code_posts.each { |p| p.post_type = 'code'; p.save }
      puts "Converted #{count} 'ruby_code' post types to 'code' post type.  You're good to go."
    else
      puts "No 'ruby_code' posts found.  You're good to go."
    end
  end
end
