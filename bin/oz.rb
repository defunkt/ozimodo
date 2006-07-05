#!/usr/bin/env ruby

#
# oz.
#   a command line t
#                    u
# by.                  m
#    chris wanstrath     b
#                          l
#       - and -              e
#                              r
#    dayne broderson
#

require 'net/http'
require 'open-uri'
require 'uri'
require 'yaml'

OZ_VERSION = '0.1'
USER_AGENT = "oz/#{OZ_VERSION}"

class OzException < Exception; end
class BadFormatOfSiteSwitch < OzException; end
class BadFormatOfLoginSwitch < OzException; end
class ConfigFileDoesntExist < OzException; end
class ConfigFileNeedsHost < OzException; end
class CantLoginWithoutHost < OzException; end
class LoginFailed < OzException; end
class HostNeeded < OzException; end

class Oz
  class << self 
    @@debug = false

    def tumble(args)
      if args.index('--clear-cache')
        clear_cache
        exit
      end

      if i = args.index('--debug')
        args.delete_at(i)
        @@debug = true
      end

      host, port, cookie = load_cache

      if args.first =~ /^--(login|site)/
        case args.first
        when '--login'
          raise CantLoginWithoutHost unless host
          user, pass = parse_login_switch(args[1])
        when '--site'
          host, user, pass, port = parse_site_switch(args[1]) 
        end
        args.slice!(0, 2)

        raise LoginFailed unless cookie = do_login(host, port, user, pass)

        info "Login successful, you don't have to use --site anymore."
        write_to_cache(:host => host, :port => port.to_i, :cookie => cookie)
      end

      error "No cache file or host info found.  Please run the script with --site user:pass@host:port." unless host

      url = build_url(host, port, args)
      headers = build_headers(cookie)

      error "No URL to hit." unless url

      debug "Hitting #{url} with headers #{headers.inspect}."
      
      open(url, headers) do |body|
        puts body.read
      end
    end

    def do_login(host, port, user, pass)
      debug "Tried to login to #{host}:#{port} as #{user}/#{pass}."
      begin
        site = Net::HTTP.new(host, port)
        res  = site.post2('/api/login', "username=#{user}&password=#{pass}", build_headers)
      rescue Errno::ECONNREFUSED 
        error "Couldn't connect to http://#{host}:#{port} to login."
      end
      (res.header['set-cookie'] =~ /(.+); path(.+)$/) ? $1 : false
    end

    def parse_site_switch(site)
      raise BadFormatOfSiteSwitch unless site =~ /^(http:\/\/)?(.+):(.+)@([^:]+):?(\d*)$/
      [$4, $2, $3, ($5.empty? ? 80 : $5)]
    end

    def parse_login_switch(login)
      raise BadFormatOfLoginSwitch unless login =~ /^(.+):(.+)$/
      [$1, $2]
    end

    def write_to_cache(options)
      cache_file = ENV['OZCACHE'] || (File.expand_path('~') + '/.ozcache')
      options.stringify_keys!
      cache = if File.exists? cache_file
                YAML.load(File.read(cache_file)).merge(options)
              else
                options
              end
      file = File.new(cache_file, 'w')
      file.write(YAML.dump(cache))
      file.close_write
      debug "Wrote #{cache.inspect} to cache file #{cache_file}."
    end

    def clear_cache
      files = [ENV['OZCACHE'], File.expand_path('~') + '/.ozcache'].compact
      info "No cache exists." if files.size == 0
      while file = files.shift
        next unless File.exists? file
        File.unlink file
        info "Deleted cache file #{file}"
      end
    end

    def load_cache
      if (file = ENV['OZCACHE']) && File.exists?(file)
      elsif (file = File.expand_path('~') + '/.ozcache') && File.exists?(file)
      else return false
      end
      yaml = YAML.load(File.read(file))
      yaml['host'] ? [yaml['host'], yaml['port'], yaml['cookie']] : false
    end

    def build_url(host, port, args)
      return unless args.size.nonzero?
      port = (port == 80) ? '' : ":#{port}"
      url  = "http://#{host}#{port}/api/"
      url << args.shift   # something like 'list' or 'show' -- the page you want to hit
      url << "/#{args.shift}" if args.size.nonzero? unless args.first =~ /^--/    # the '33' part of /api/show/33

      # turns --link http://ozmm.org into &post[link]=http://ozmm.org
      sep = '?'
      while arg = args.shift
        next unless arg =~ /^--(\w+)/
        url << "#{sep}post[#{$1}]=#{args.shift}"
        sep = '&'
      end if args.size.nonzero?

      url = URI.escape(url)
      debug "Built url #{url}"
      url
    end

    def build_headers(cookie = nil)
      headers = { 'User-Agent' => USER_AGENT, 'Accept' => 'text/plain' }
      cookie ? headers.merge('Cookie' => cookie) : headers
    end

    def error(msg)
      puts "=> #{msg}"
      exit
    end

    def info(msg)
      puts "=> #{msg}"
    end

    def debug(msg)
      info msg if @@debug
    end

  end
end

class Hash
  def stringify_keys!
    keys.each do |key|
      unless key.class.to_s == "String"
        self[key.to_s] = self[key]
        delete(key)
      end
    end
    self
  end
end

Oz.tumble(ARGV.dup) if $0 == __FILE__
