require 'action_controller/railtie'

module TestRailsApp
  class Application < Rails::Application
    config.secret_token = '572c86f5ede338bd8aba8dae0fd3a326aabababc98d1e6ce34b9f5'
    if Rails::VERSION::MAJOR > 3
      config.secret_key_base = '6dfb795086781f017c63cadcd2653fac40967ac60f621e6299a0d6d811417156d81efcdf1d234c'
    end

    routes.draw do
      get  '/'   => 'test_rails_app/sessions#new'
      get '/test_session' => 'test_rails_app/sessions#test_session'
      post '/test_form' => 'test_rails_app/sessions#test_session'
    end
  end

  class SessionsController < ActionController::Base
    prepend_view_path 'apps'
    def new
      session[:test] = "Found"
    end

    def test_session
      if session[:test].blank?
        render :text => "Session not found"
      else
        render :text => "Session found"
      end
    end
  end
end

Rails.logger = Logger.new('/dev/null')
# Rails.logger = Logger.new(STDOUT)
