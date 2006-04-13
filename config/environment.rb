# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

RAILS_GEM_VERSION = '1.1.2'
OZIMODO_VERSION = '1.1.4'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"  
end

# load yaml config file, mostly for rss and api
TUMBLE = YAML.load( File.open( File.dirname(__FILE__) + '/tumble.yml' ) )

# initialize constants
TYPES = []
YAML_TYPES = HashWithIndifferentAccess.new

# figure out what type of post types we have by looking in the types directory for partials
# for each partial, check the first line for fields: 
# if it exists, arrayize the arguments and add the array to YAML_TYPES[:type]
Dir[File.dirname(__FILE__) + '/../components/' + TUMBLE['component'] + '/tumble/types/*'].each do |f|
  # get the name of this type
  type = File.basename(f).sub(/^_/,'').sub('.rhtml','')
  # add the post type to our TYPES constant
  TYPES << type
  # grab the first line to see if the post type needs a YAMLized content variable 
  first_line = File.readlines(f)[0]  
  # if the first line contains 'fields:', run it through the fields parser  
  YAML_TYPES[type] = first_line.gsub(/(<%#|%>|-%>|fields:)/, '').split if first_line['fields:']
end

# version check information
VERSION_CHECK = { :domain => 'http://ozimodo.rubyforge.org', :port => 80,
                  :page => '/current_version.txt' }
