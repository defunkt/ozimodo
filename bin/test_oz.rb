require 'test/unit'
require 'fileutils'
require 'tempfile'
require 'oz'

class OzTest < Test::Unit::TestCase

  def test_load_cache_from_env
    ENV['OZCACHE'] = 'ozimondo'   
    file = File.new('ozimondo', 'w')
    file.write <<-MONDO
    --- 
    host: ozmm.org
    port: 80
    cookie: crazy#RJrj3rhQ#ROHr3$TOhy4--
    MONDO
    file.close_write
    assert_equal ['ozmm.org', 80, 'crazy#RJrj3rhQ#ROHr3$TOhy4--'], Oz.load_cache
    FileUtils.rm 'ozimondo'
  end

  def test_write_host_to_cache
    ENV['OZCACHE'] = 'ozicachedo'
    Oz.write_to_cache(:host => 'ozmm.org')
    assert_equal 'ozmm.org', YAML.load(File.read('ozicachedo'))['host']
    FileUtils.rm 'ozicachedo'
  end

  def test_write_host_and_port_to_cache
    ENV['OZCACHE'] = 'ozidom'
    Oz.write_to_cache(:host => '127.0.0.1', :port => 3000)
    assert_equal '127.0.0.1', YAML.load(File.read('ozidom'))['host']
    assert_equal 3000, YAML.load(File.read('ozidom'))['port']
    FileUtils.rm 'ozidom'
  end

  def test_do_login_good
    assert_equal 'ozimodo=cookiecookie', Oz.do_login('ozmm.org', 80, 'cookie', 'monster')
  end

  def test_parse_site_switch_good
    args = %w[--site chris:jimmy@ozmm.org] 
    assert_equal %w[ozmm.org chris jimmy] + [''], Oz.parse_site_switch(args.last)
  end
  
  def test_parse_site_switch_with_http
    args = %w[--site http://jimmy:chris@ozmm.org] 
    assert_equal %w[ozmm.org jimmy chris] + [''], Oz.parse_site_switch(args.last)
  end

  def test_parse_site_switch_with_port
    args = %w[--site http://local:host@ozmm.org:3000]
    assert_equal %w[ozmm.org local host 3000], Oz.parse_site_switch(args.last)
  end

  def test_parse_site_switch_no_auth
    args = %w[--site http://ozmm.org] 
    assert_raises(BadFormatOfSiteSwitch) do
      Oz.parse_site_switch(args.last)
    end
  end
  
  def test_parse_site_switch_bad
    args = %w[--site chris!@ozmm.org] 
    assert_raises(BadFormatOfSiteSwitch) do 
      Oz.parse_site_switch(args.last)
    end
  end

  def test_parse_login_switch
    args = %w[--login chris:jimmy]
    assert_equal %w[chris jimmy], Oz.parse_login_switch(args.last)
  end

  def test_parse_login_switch_bad
    args = %w[--login chris!jimmy]
    assert_raises(BadFormatOfLoginSwitch) do
      Oz.parse_login_switch(args.last)
    end
  end

  def test_build_url_no_params
    host = 'ozmm.org'
    port = 80
    args = %w[list]
    assert_equal 'http://ozmm.org/api/list', Oz.build_url(host, port, args)
  end

  def test_build_url_one_param
    host = 'ozimodo.net'
    port = 3000
    args = %w[show 55]
    assert_equal 'http://ozimodo.net:3000/api/show/55', Oz.build_url(host, port, args)
  end

  def test_build_url_to_post
    host = 'ozmm.org'
    port = 80
    args = %w[image --src http://ozmm.org/puppy.jpg --alt aww --tags photo]
    assert_equal 'http://ozmm.org/api/image?post[src]=http://ozmm.org/puppy.jpg&post[alt]=aww&post[tags]=photo',
                 Oz.build_url(host, port, args)
  end

  def test_build_url_to_post_again
    host = 'ozmm.org'
    port = 80
    args = %w[link --link http://hotchicks.com --quip babybaby!]
    assert_equal 'http://ozmm.org/api/link?post[link]=http://hotchicks.com&post[quip]=babybaby!',
                 Oz.build_url(host, port, args)
  end

  def test_build_url_to_post_is_escape
    host = 'ozmm.org'
    port = 80
    args = %w[link --link http://hotchicks.com --quip] + ['baby baby!']
    assert_equal 'http://ozmm.org/api/link?post[link]=http://hotchicks.com&post[quip]=baby%20baby!',
                 Oz.build_url(host, port, args)
  end

  def test_build_headers
    expected = { 'User-Agent' => USER_AGENT, 'Accept' => 'text/plain' }
    assert_equal expected, Oz.build_headers
  end

  def test_stringify_keys_bang
    hash = { :make => 'Apple', :model => 'Powerbook' }
    hash.stringify_keys!
    assert_equal %w[make model], hash.keys.sort
  end

  def test_clear_cache
    $stdout = Tempfile.new('tmp')
    ENV['OZCACHE'] = 'clearme'
    FileUtils.touch 'clearme'
    assert_equal true, File.exists?('clearme')
    Oz.clear_cache
    assert_equal false, File.exists?('clearme')
  end

end

module Net
  class FakeResponse
    attr_reader :header
    def initialize(params, headers)
      @header = { 'set-cookie' => 'ozimodo=cookiecookie; path=/' }
    end
  end
  class HTTP
    def post2(uri, params, headers)
      FakeResponse.new(params, headers)
    end
  end
end
