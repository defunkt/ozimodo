module Ozimodo
  module Plugins
    @@admin_links, @@plugins = {}, []
    mattr_reader :admin_links
    mattr_reader :plugins

    class << self

      def register(plugin)
        Dir[File.join(plugin_path(plugin), '**', '**')].each do |file|
          if file =~ /init\.rb$/ 
            load file
          else
            require_dependency file if /\.rb$/ =~ file
          end
        end
        @@plugins << plugin
      end

      def admin_method(plugin, method = nil, link_to_name = nil, &block)
        method = plugin if method.nil?
        @@admin_links[method] = (link_to_name ? link_to_name : method.to_s) unless link_to_name == false
        AdminController.send(:define_method, method, &block)
      end

      def migrate(plugin, direction)
        return unless File.exists?("#{migration_file = File.join(plugin_path(plugin), 'install', 'migration')}.rb")
        require migration_file
        Object.const_get("#{plugin.camelize.to_s}Migration").migrate(direction)
      end

      def plugin_path(plugin)
        File.join(THEME_DIR, 'plugins', plugin.to_s)
      end

      def plugin_paths
        @@plugins.map { |p| plugin_path(p) }
      end

    end
  end
end
