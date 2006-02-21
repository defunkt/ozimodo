require File.dirname(__FILE__) + '/../test_helper'

require 'post'
require 'tag'

# raise errors big time
class Tag; def rescue_action(e) raise e end; end

class TagTest < Test::Unit::TestCase
  fixtures :posts, :tags, :posts_tags

end