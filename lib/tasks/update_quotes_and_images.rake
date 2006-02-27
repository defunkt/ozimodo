desc "Convert quotes and image entries from plaintext to YAML"
task :update_quotes_and_images => :environment do
  # disable auto-yamlin' of special types
  YAML_TYPES = nil
    
  # grab all the quotes in the db
  quotes = Post.find(:all, :conditions => "post_type = 'quote'")
  # for each quote, convert the content from a string to YAML, then store it
  quotes.each do |q|
    begin
      content_hash = YAML.load(q.content)
    rescue
      content_hash = nil
    end
    q.content = {'quote' => q.content}.to_yaml unless content_hash.is_a? Hash
    q.save
  end

  # grab all the images in the db
  images = Post.find(:all, :conditions => "post_type = 'image'")
  # for each quote, convert the content from a string to YAML, then store it
  images.each do |i|
    begin
      content_hash = YAML.load(i.content)
    rescue
      content_hash = nil
    end
    i.content = {'src' => i.content}.to_yaml unless content_hash.is_a? Hash
    i.save
  end
end
