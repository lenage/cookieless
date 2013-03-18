module Rack
  module Cookieless
    class Middleware
      include Rack::Cookieless::Functions
      def initialize(app, options={})
        @app =app
        @options = options
      end

      def call(env)
        if supports_cookies? || noconvert
          @app.call(env)
        else
          session_id = get_session_id_from_query()
          set_cookie_by_session_id(session_id)

          status, header, response = @app.call(env)

          if page_warrants_cookie?
            session_id ||= env["rack.session"]["session_id"]
            cache_cookie_by_session_id(session_id, header["Set-Cookie"])
            fix_url(header["Location"],session_id)
            if process_page?
              if page_has_body?
                if content_is_arrayed?(response.body)
                  process_body(response.body[0],session_id)
                else
                  process_body(response.body,session_id)
                end
              else
                if content_is_arrayed?(response)
                  process_body(response[0],session_id)
                end
              end
            end
          end
          [status, header, response]
        end
      end
    end
  end
end
