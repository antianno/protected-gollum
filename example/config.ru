# this is a Rack config, not a gollum config.rb!
# protected-gollum is written for a Rack environment
# start with 'rackup' (or 'unicorn', 'puma', or something), NOT 'gollum --config ...'
# another disclaimer: only tested with MRI ruby 2.3 under Linux
require 'gollum/app'

# protected-gollum uses sessions but does not enable them explictly,
# so something like this is required! there is actually a good reason for this,
# as explained in the README ;)
require 'rack/session/pool'
use Rack::Session::Pool, :expire_after => 2592000

# Gollum configuration
wiki_options = {
  h1_title: true,
  live_preview: false,
}
Precious::App.set :gollum_path, '/tmp/gollum'
Precious::App.set :wiki_options, wiki_options

# protected-gollum "configuration"
require 'protected-gollum'
ProtectedGollum::User.file = File.expand_path('users.json', File.dirname(__FILE__)) # contains user test:test
Precious::App.register ProtectedGollum
# to generate password hashes for users.json, use 'mkunixcrypt' (binary in 'unix-crypt' gem, which is a dependency)

run Precious::App
