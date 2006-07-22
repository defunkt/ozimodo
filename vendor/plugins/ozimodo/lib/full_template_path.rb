module ActionView
  class Base
    private
      def full_template_path(template_path, extension)
        # If the template exists in the normal application directory,
        # return that path
        default_template = "#{@base_path}/#{template_path}.#{extension}"
        return default_template if File.exist?(default_template)

        # Otherwise, check in the engines to see if the template can be found there.
        # Load this in order so that more recently started Engines will take priority.
        Ozimodo::Plugins.plugin_paths.each do |path|
          site_specific_path = File.join(path, 'views', template_path.to_s + '.' + extension.to_s)
          return site_specific_path if File.exist?(site_specific_path)
        end

        # If it cannot be found anywhere, return the default path, where the
        # user *should* have put it.
        return "#{@base_path}/#{template_path}.#{extension}"
      end
  end
end
