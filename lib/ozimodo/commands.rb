require File.join(RAILS_ROOT, 'lib', 'ozimodo', 'plugins')

module Ozimodo
  class Commands
    class << self
      
      def parse!(args)
        self.send(cmd = args.shift, args) #rescue help
      end

      def plugin(args)
        self.send("plugin_#{args.shift}", args.first)
      end

      def plugin_install(plugin)
        Ozimodo::Plugins.migrate(plugin, :up)
      end

      def plugin_uninstall(plugin)
        Ozimodo::Plugins.migrate(plugin, :down)
      end

      def help
        puts "Usage: ozimodo <command> [options]"
        puts
        puts "Available commands:"
        puts 
        puts "  plugin install <plugin>      Installs an ozimodo plugin."
        puts "  plugin uninstall <plugin>    Uninstalls an ozimodo plugin."
      end

    end
  end
end

Ozimodo::Commands.parse!(ARGV)
