require 'capybara/rspec'
require 'cookieless'

Dir[File.expand_path('../../apps/*.rb', __FILE__)].each do |f|
  require f
end

TestRailsApp::Application.configure do |app|
  app.middleware.insert_before ActionDispatch::Cookies, Rack::Cookieless::Middleware, :session_id => :si
end
