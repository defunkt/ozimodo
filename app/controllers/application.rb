class ApplicationController < ActionController::Base
  session :disabled => true

  def self.theme_dir
    THEME_DIR
  end
  def theme_dir
    self.class.theme_dir
  end
end

# theme_init
require_dependency File.join(THEME_DIR, 'theme_init') if File.exists?(File.join(THEME_DIR, 'theme_init.rb'))
