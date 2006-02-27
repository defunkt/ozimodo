desc "Convert quotes and image entries from plaintext to YAML"
task :update_quotes_and_images => :environment do
  # grab all the quotes in the db
  quotes = Post.find(:all, :conditions => "post_type = 'quote'")
  # for each quote, convert the content from a string to YAML, then store it
  quotes.each do |q|
    q.content = {'quote' => q.content}.to_yaml unless q.content.is_a? Hash
    q.save
  end

  # grab all the images in the db
  images = Post.find(:all, :conditions => "post_type = 'image'")
  # for each quote, convert the content from a string to YAML, then store it
  images.each do |i|
    i.content = {'src' => i.content}.to_yaml unless i.content.is_a? Hash
    i.save
  end
end
