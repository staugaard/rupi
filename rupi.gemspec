# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rupi/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rupi'
  gem.version       = Rupi::VERSION

  gem.authors       = ['Mick Staugaard']
  gem.email         = ['mick@staugaard.com']
  gem.description   = 'A avery simple ruby library for Raspberry Pi GPIO'
  gem.summary       = 'Provides a very natural ruby interface for interacting with GPIO on the Raspberry Pi'
  gem.homepage      = ''

  gem.files         = Dir.glob('{bin,lib,test}/**/*') + ['README.md']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'wiringpi'
  gem.add_dependency 'daemons'

  gem.add_development_dependency 'rake'
end
