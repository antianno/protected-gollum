require 'json'
require 'unix_crypt'
require 'sinatra/base'

module ProtectedGollum

  # Constants
  LOGIN_PAGE     = File.expand_path('login.html', File.dirname(__FILE__))
  ROUTE_PREFIX   = '/__protected__'
  FAVICON        = '/favicon.ico'
  SESSION_UID    = 'protected-gollum.uid'
  SESSION_ORIGIN = 'protected-gollum.origin'

  # User class, backed by a JSON file
  class User
    def self.file=(path)
      @file = path
    end
    def self.file
      raise IOError, 'ProtectedGollum::User.file is not set!' if @file.nil? || @file.empty?
      @file
    end
    def self.authenticate(uid, password_cleartext)
      user = get(uid)
      user ? user.authenticate(password_cleartext) : false
    end
    def self.get(uid)
      all.find { |user| user.uid == uid }
    end
    def self.all
      @all ||= parse_all
    end
    def self.parse_all
      json_file = file
      begin
        users = JSON.parse(IO.read(json_file))
        raise unless users.is_a? Array
        return users.map! { |user| User.new(user) }
      rescue
        raise ArgumentError, "'#{json_file}' must contain a JSON array of objects, each with the fields 'uid', 'name', 'email', 'password'!"
      end
    end
    # ---
    attr_reader :uid, :name, :email
    def initialize(json_hash)
      if json_hash.is_a? Hash
        @uid      = json_hash['uid']
        @name     = json_hash['name']
        @email    = json_hash['email']
        @password = json_hash['password']
      end
      raise if [@uid, @name, @email, @password].any? { |val| val.nil? || !(val.is_a? String) || val.empty? }
    end
    def authenticate(password_cleartext)
      self if UnixCrypt.valid?(password_cleartext, @password)
    end
  end

  # Sinatra Helpers
  module Helpers
    def login
      authenticate! if request.post?
      get_user ? redirect(session.delete(SESSION_ORIGIN) || '/')
               : send_file(LOGIN_PAGE)
    end
    def logout
      reset_user
      redirect('/')
    end
    def protect!
      unless @user = get_user
        session[SESSION_ORIGIN] = request.path unless (request.path.empty? || request.path.include?(ROUTE_PREFIX))
        redirect(ROUTE_PREFIX + '/login')
      end
    end
    # ---
    def reset_user
      session.delete SESSION_UID
      session.delete 'gollum.author'
    end
    def get_user
      (uid = session[SESSION_UID]) && User.get(uid)
    end
    def authenticate!
      reset_user
      if user = User.authenticate(params[:login], params[:password])
        session[SESSION_UID] = user.uid
        session['gollum.author'] = {name: user.name, email: user.email}
      end
    end
  end

  # Sinatra Extension
  def self.registered(app)
    app.helpers Helpers
    # /login
    app.before(ROUTE_PREFIX + '/login')  { login  }
    # /logout
    app.before(ROUTE_PREFIX + '/logout') { logout }
    # avoid getting redirected to 'favicon dot ico' creation page (gollum doesn't serve a favicon anyway)
    app.before(FAVICON) { halt 404 }
    # protect everything else
    app.before() { protect! }
  end
end
