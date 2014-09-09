# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_tenant/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'active_tenant'
  s.version       = ActiveTenant::VERSION
  s.authors       = ['Gabriel Naiman']
  s.email         = ['gabynaiman@gmail.com']
  s.description   = 'ActiveRecord extensions for multi tenant applications'
  s.summary       = 'ActiveRecord extensions for multi tenant applications'
  s.homepage      = 'https://github.com/gabynaiman/active_tenant'

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord', '~> 3'

  if RUBY_ENGINE == 'jruby'
    s.add_development_dependency 'activerecord-jdbcpostgresql-adapter'
    s.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
  else
    s.add_development_dependency 'pg'
    s.add_development_dependency 'sqlite3'
  end
  s.add_development_dependency 'rspec', '~> 2.14.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
end
