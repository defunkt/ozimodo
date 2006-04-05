# helpers you put in here will be accessible to your tumblelog and are 
# super portable.  if you're looking for the core ozi helpers, check out
# app/helpers/tumble_helper.rb
module ComponentHelper  
  
  # get an array of tag names and generate a comma separated, linked string of tags
  def linked_tags_with_commas(tags)
    linked = []
    tags.each do |tag|
      linked << link_to(tag.name, :controller => 'tumble', :action => 'tag', :tag => tag.name)
    end
    linked.join(', ')
  end
  
end