# adds a 'text' method to the response object
# => respond_to do |type|
#      type.text { render :text => 'wheeee' }
#    end
require File.dirname(__FILE__) + '/lib/mime_text'
