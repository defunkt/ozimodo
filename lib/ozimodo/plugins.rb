module Ozimodo
  module Plugins
    @@admin_links = {}
    mattr_reader :admin_links

    class << self

      def register(plugin)
        Dir[File.join(plugin_path(plugin), '**', '**')].each do |file|
          if file =~ /init\.rb$/ 
            load file
          else
            require_dependency file if /\.rb$/ =~ file
          end
        end
      end

      def admin_method(plugin, method, link_to_name = nil, &block)
        @@admin_links[method] = link_to_name ? link_to_name : method.to_s
        plugin_path = File.join(plugin_path(plugin), 'views', 'admin', "#{method.to_s}.rhtml")
        AdminController.send(:define_method, method) do
          block.call
          @page_name = method.to_s
          file = plugin_path
          raise "Can't find #{file} to render." unless File.exists?(file)
          render :file => file, :layout => nil
        end
      end

      def migrate(plugin, direction)
        return unless File.exists?("#{migration_file = File.join(plugin_path(plugin), 'install', 'migration')}.rb")
        require migration_file
        Object.const_get("#{plugin.camelize.to_s}Migration").migrate(direction)
      end

    protected

      def plugin_path(plugin)
        File.join(THEME_DIR, 'plugins', plugin.to_s)
      end

    end
  end
end
