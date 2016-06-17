# protected-gollum

A tiny authentication library for [gollum](https://github.com/gollum/gollum),
written for use in a private wiki installation. Hardly configurable, but
dead simple. It reads the authorized users from a simple JSON file and
protects everything.

Heavily inspired by [omnigollum](https://github.com/arr2036/omnigollum)!

## Quickstart

```bash
git clone https://github.com/antianno/protected-gollum.git
cd protected-gollum
gem build protected-gollum.gemspec
gem install protected-gollum*.gem
cd example
# Customize :gollum_path in config.ru
rackup
# Example users.json contains the user test:test
```

## JSON file format

Rather self-explanatory, except for the `password` field maybe:

```json
[
  {"uid": "username", "name": "Real Name", "email": "mail@example.org", "password": "$6$7rv..."}
]
```

* The fields `name` and `email` will be used for the commit history.
* The password is expected to be hashed in the same format as `/etc/shadow` entries,
  preferably using salted SHA-512.
* The `mkunixcrypt` utility from the unix-crypt RubyGem (which is a protected-gollum
  dependency) generates such hashes.

## Motivation

Why writing another authentication library with fewer features than omnigollum?!
After all, using [omniauth-identity](https://github.com/intridea/omniauth-identity),
one might have implemented the same JSON-file based authentication scheme.

Which I did!

Not to reinvent the wheel, but it bothered me that I wasn't able to configure the
Rack session backend (`:expire_after` in particular), so the session cookie expires
everytime the browser is closed, and authentication is necessary again.

As I understand it, the reason for this is that omnigollum explicitly enables sessions
with `app.set :sessions, true` (which makes sense), but in Sinatra this is hard-coded
to `use Rack::Session::Cookie` with some sane defaults, unfortunately without the
`:expire_after` option.

By the time I figured this out, basically the entirety of omnigollum's source was
in my head anyway and shortly thereafter protected-gollum was written from scratch.
Why not?

## Remarks

As mentioned in the example config.ru and explained above, protected-gollum uses
Sinatra's `session` but does not enable it, so something like the following is
*required* in the rack config:

```ruby
require 'rack/session/pool'
use Rack::Session::Pool, :expire_after => 2592000
```

*(Also, I didn't bother to find out how to do this with a gollum config.rb)*

The JSON file containing the users is read only once and gollum needs to be
restarted if users are added/modified/removed.

**Other missing features**

A lot ;)

* Login page not configurable and references Bootstrap CSS files on their CDN
  (so it might be ugly when used offline)
* Adding/modifying/removing users only by editing the JSON file by hand
* Everything is protected, no way to configure it (to have a read-only wiki,
  as is the default with omnigollum, for example)
* Definitely no ACLs, every user can do everything

## Proper Setup

There are currently no plans to publish this to [RubyGems.org](https://rubygems.org/),
to use this with `bundle` one can put something like this in the Gemfile:

```ruby
source 'https://rubygems.org'
gem 'gollum', :git => 'https://github.com/antianno/gollum.git'
gem 'protected-gollum', :git => 'https://github.com/antianno/protected-gollum.git'
# and for example:
gem 'puma'
```

The gollum fork features a Logout button (when viewing a page, not everywhere,
e.g. not in the History view etc.) and some minor modifications of the CSS,
mainly to let the browser decide what fonts to use.

## Credits

* [arr2036](https://github.com/arr2036) for [omnigollum](https://github.com/arr2036/omnigollum),
  which was a fine example for how to implement authentication for gollum
* The [Bootstrap developers](https://getbootstrap.com/) for, well, Bootstrap
