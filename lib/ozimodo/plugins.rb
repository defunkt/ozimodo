module Ozimodo
  class Plugins
    @@admin_links = {}
    cattr_reader :admin_links

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
        AdminController.send(:define_method, method) do
          block.call
          @page_name = method.to_s
          file = File.join(plugin_path(plugin), 'views', 'admin', "#{method.to_s}.rhtml")
          raise "Can't find #{file} to render." unless File.exists?(file)
          render :file => file, :layout => nil
        end
      end

    protected

      def plugin_path(plugin)
        File.join(THEME_DIR, 'plugins', plugin.to_s)
      end

    end
  end
end
