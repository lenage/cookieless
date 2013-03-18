require 'capybara/rspec'
require 'cookieless'
require "racktest_cookie_disabler"
require "racktest_cookie_disabler/capybara"
require "test_store"

Dir[File.expand_path('../../apps/*.rb', __FILE__)].each do |f|
  require f
end


TestRailsApp::Application.configure do
  config.middleware.insert_after Rack::Lock, RackTestCookieDisabler::Middleware
  config.middleware.insert_before ActionDispatch::Cookies, Rack::Cookieless::Middleware, :session_id => :si, :cache_store => TestStore.new
end
