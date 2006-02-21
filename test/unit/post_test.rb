require File.dirname(__FILE__) + '/../test_helper'

require 'post'
require 'tag'

# raise errors big time
class Post; def rescue_action(e) raise e end; end

class PostTest < Test::Unit::TestCase
  fixtures :posts, :tags, :posts_tags

  def test_get_tag_names
    assert_equal "#{@post_kids.tags[0].name} #{@post_kids.tags[1].name}", 
                    @post_kids.tag_names
  end

  def test_set_tag_names
    tags_string = "rock dinosaur"
    @post_kids.tag_names = tags_string
    @post_kids.save
    assert_equal tags_string.split.size, @post_kids.tags.size
    assert_equal tags_string, @post_kids.tag_names
  end
  
  def test_prune_tags
    tags_string = "#{@tag_ruby.name} #{@tag_rock.name}"
    @post_spacetime.tag_names = tags_string
    @post_spacetime.save
    assert_equal tags_string.split.size, @post_spacetime.tags.size
    assert_equal 4, Tag.find(:all).size
  end
  
  def test_get_posts_with_tags_by_array
    tags_array = [ @tag_ruby.name, @tag_rock.name ]
    posts = Post.find_by_tags( tags_array )
    assert_equal @tag_ruby.posts & @tag_rock.posts, posts
  end
  
  def test_get_posts_with_tags_lose
    assert_raise( MultiPostFindExpectsArray ) { Post.find_by_tags( false ) }
  end
  
  def test_get_posts_with_tags_by_string
    tags_string = "#{@tag_ruby.name} #{@tag_rock.name}"
    posts = Post.find_by_tags( tags_string )
    assert_equal @tag_ruby.posts & @tag_rock.posts, posts
  end
end