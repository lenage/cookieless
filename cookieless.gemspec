# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cookieless/version'

Gem::Specification.new do |gem|
  gem.name = "cookieless"
  gem.version = Rack::Cookieless::VERSION

  gem.authors = ["Jinzhu", "chrisboy333"]
  gem.date = "2012-01-06"
  gem.email = "wosmvp@gmail.com"
  gem.files = `git ls-files`.split($/)
  gem.description = "Cookieless is a rack middleware to make your application works with cookie-less devices/browsers without change your application"
  gem.summary = "Cookieless is a rack middleware to make your application works with cookie-less devices/browsers without change your application"
  gem.homepage = "http://github.com/jinzhu/cookieless"

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'nokogiri'

  gem.add_development_dependency 'rspec', '2.12.0'
  gem.add_development_dependency 'capybara', '1.1.4'
  gem.add_development_dependency 'racktest_cookie_disabler'
  gem.add_development_dependency 'rails', '3.2.12'
end
