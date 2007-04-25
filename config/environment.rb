# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

RAILS_GEM_VERSION = '1.2.3'
OZIMODO_VERSION = '1.2.2'
ENV['RAILS_ASSET_ID'] = Time.now.to_i.to_s

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/themes )

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.action_controller.page_cache_directory = File.join(RAILS_ROOT, 'public', 'cache')
  
  # Tell Rails to look in the /vendor/gems/ directory for all gem requires
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end
end

# load yaml config file, mostly for rss and api
TUMBLE = YAML.load(File.open(File.join(File.dirname(__FILE__), 'tumble.yml')))

# initialize constants
TYPES = {}

THEME_DIR = File.join(RAILS_ROOT, 'themes', TUMBLE['theme'])

# figure out what type of post types we have by looking in the types directory for partials
# for each partial, check the first line for fields: 
# if it exists, arrayize the arguments and add the array to TYPES[:type]
Dir[File.join(THEME_DIR, 'tumble', 'types', '*')].each do |f|
  TYPES[File.basename(f).sub(/^_/,'').sub('.rhtml','')] = Ozimodo::TypeParser.parse_file(f)
end

TYPES.freeze

# api config / help
API = {}
API[:help_yaml] = YAML.load(File.open(File.join(RAILS_ROOT, 'config', 'api', 'help.yml')))

# version check information
VERSION_CHECK = { :domain => 'http://ozimodo.rubyforge.org', :port => 80,
                  :page => '/current_version.txt' }

# load theme .rb files
$LOAD_PATH << THEME_DIR

# load dependencies
require 'vendor/RedCloth/lib/redcloth'

# wipe cache dir
CacheSweeper.sweep
