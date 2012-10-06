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

  s.add_dependency 'rails', '>= 3.2.0'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec'
end
