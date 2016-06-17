Gem::Specification.new do |s|

  s.name          = 'protected-gollum'
  s.version       = '0.1'
  s.authors       = ['Alex Dircksen']
  s.email         = ['antianno52@gmail.com']

  s.summary       = 'Authentication for Gollum, the simple, Git-powered wiki.'
  s.description   = 'Lightweight authentication library for Gollum, reading user accounts from a simple JSON file.'
  s.homepage      = 'https://github.com/antianno/protected-gollum/'
  s.license       = 'MIT'

  s.require_paths = ['lib']
  s.executables   = []

  s.add_dependency 'gollum', '~> 4.0'
  s.add_dependency 'unix-crypt', '~> 1.3'

  # = MANIFEST =
  s.files = %w[
    lib/login.html
    lib/protected-gollum.rb
    Gemfile
    protected-gollum.gemspec
    LICENSE
    README.md
  ]
  # = MANIFEST =

end
