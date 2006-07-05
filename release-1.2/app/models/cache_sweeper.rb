#
# we destroy the entire cache whenever a change is made.
# our caching model is inspired by http://www.fngtps.com/2006/01/lazy-sweeping-the-rails-page-cache
#
class CacheSweeper < ActionController::Caching::Sweeper
  observe Post, Tag

  def after_save(record)
    self.class.sweep
  end

  def after_destroy(record)
    self.class.sweep
  end

  def self.sweep
    cache_dir = ActionController::Base.page_cache_directory
    unless cache_dir == "#{RAILS_ROOT}/public"
      FileUtils.rm_r(Dir.glob("#{cache_dir}/*")) rescue Errno::ENOENT
      RAILS_DEFAULT_LOGGER.info("Cache directory '#{cache_dir}' fully swept.")
    end
  end
end
