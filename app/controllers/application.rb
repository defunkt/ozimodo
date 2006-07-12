class ApplicationController < ActionController::Base
  session :off

  def self.theme_dir
    File.join(RAILS_ROOT, 'themes', TUMBLE['theme'])
  end
  def theme_dir
    self.class.theme_dir
  end
end

# theme_init
require_dependency "themes/#{TUMBLE['theme']}/theme_init" if File.exists?(File.join(RAILS_ROOT, 'themes', TUMBLE['theme'], 'theme_init.rb'))
