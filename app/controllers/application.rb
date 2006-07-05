class ApplicationController < ActionController::Base
  session :off

  def self.theme_dir
    File.join(RAILS_ROOT, 'themes', TUMBLE['theme'])
  end
  def theme_dir
    self.class.theme_dir
  end
end
