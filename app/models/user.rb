#
# Inspired by the authentication example in the Pragmatic Programmers'
# Agile Web Development with Ruby on Rails.  Nothing too crazy.
#

class CantDestroyAdminUser < StandardError; end
  
  
class User < ActiveRecord::Base
  has_many :posts, :order => 'created_at DESC'
 
  before_destroy :dont_destroy_admin
  
  attr_accessor   :password
  attr_accessible :name, :password
  
  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_presence_of   :password, :on => :create
  
  def before_save
    # hash the plaintext password and set it to an instance variable
    self.hashed_password = User.hash_password(self.password)
  end
  
  def after_save
    # get rid of the plaintext password
    @password = nil
  end
  
  def self.hash_password(password)
    require 'digest/sha1'
    
    # create a hash of plaintext
    Digest::SHA1.hexdigest(password)
  end
  
  def self.login(name, password)
    # get the user info for anyone matching name and password
    hashed_password = hash_password(password || "")
    find(:first, :conditions => ["name = ? and hashed_password = ?", 
                  name, hashed_password])
  end
  
  def try_to_login
    # return a user if we find anything
    User.login(self.name,self.password)
  end
  
  def dont_destroy_admin
    # that's you.
    raise CantDestroyAdminUser if self.id == 1 
  end
end