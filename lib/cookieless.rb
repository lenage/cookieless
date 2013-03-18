require 'digest/sha1'
require 'uri'
require 'cookieless/functions'
module Rack
  module Cookieless
     autoload :Middleware, 'cookieless/middleware'
  end
end
