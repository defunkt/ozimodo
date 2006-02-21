require File.dirname(__FILE__) + '/../test_helper'

require 'user'

# raise errors big time
class User; def rescue_action(e) raise e end; end

# let us access hashed_password for our evil purposes
class User; attr_accessor :hashed_password; end

class UserTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @admin.password = 'raptor'
  end
  
  def test_email_saves
    user = User.new(@admin)
    user.save
    assert_equal @admin.email, user.email
  end

  def test_good_login
    user = User.new( :name => @admin.name, :password => @admin.password )
    user.try_to_login
    assert_equal @admin.hashed_password, user.hashed_password
    assert_equal @admin.name, user.name
  end
  
  def test_bad_login
    user = User.new( :name => @admin.name, :password => "kiddywampus" )
    assert_nil user.try_to_login
  end
  
  def test_password_after_save
    require 'digest/sha1'
    password = "theygowild"
    user = User.new( :name => "fez", :password => password )
    user.save
    assert_nil user.password
    assert_equal Digest::SHA1.hexdigest( password ), user.hashed_password
  end
  
  def test_dont_destroy_admin
    assert_raise( CantDestroyAdminUser ) { @admin.destroy }
  end

end