require 'digest/md5'

module Ozimodo::CookieAuth
  SALT = "ahal3th8iht3a#T*Hhas"

  def set_logged_in(user, permanent = false)
    set_cookie(user.id, user.name, permanent)
  end

  def set_logged_out
    clear_cookie
  end

  def logged_in?
    load_cookie unless @cookie_loaded
    @cookie_data ? true : false
  end

  def current_user
    load_cookie unless @cookie_loaded
    @cookie_data
  end
  
  def load_cookie
    @cookie_data = get_cookie
    @cookie_loaded = true

    if @cookie_data
      logger.debug "Loaded cookie: id=#{@cookie_data[:id]}, name=#{@cookie_data[:name]}" if logger
    else
      logger.debug "No cookie to load" if logger
    end
  end

  def set_cookie(id, name, permanent = false)
    expire = (permanent ? 2.weeks.from_now : false)
    cookies[:ozimodo] = { :value => [id, name, hash(id, name)].join('&'), :expires => expire }
  end

  def get_cookie
    if cookies[:ozimodo] && cookies[:ozimodo] =~ /^(\d+)&([\w ]+)&(.+)$/u && hash_valid?($1, $2, $3)
      { :id => $1.to_i, :name => $2, :hash => $3 }
    else
      nil
    end
  end

  def hash(id, name)
    salt = (TUMBLE && TUMBLE['salt'] ? TUMBLE['salt'] : nil) || SALT
    Digest::MD5.hexdigest([salt, id, name].join(',' ))
  end

  def hash_valid?(id, name, hash)
    hash == hash(id, name)
  end
  
  def clear_cookie
    cookies.delete(:ozimodo)
  end
end
