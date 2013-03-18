require "rack"
module Rack
  module Cookieless
    module Functions
      def supports_cookies?
        !env['HTTP_COOKIE'].nil?
      end

      def noconvert
        @options[:noconvert].is_a?(Proc) ? @options[:noconvert].call(env) : false
      end

      def get_session_id
        session_id = get_session_id_from_query(env["QUERY_STRING"])
        return session_id unless session_id.empty?
        if env["HTTP_REFERER"]
          query = URI.parse(env["HTTP_REFERER"]).query
          get_session_id_from_query(query)
        end
      end

      def remote_ip
        if forwarded = env["HTTP_X_FORWARDED_FOR"]
          forwarded.split(",").first
        elsif addr = env["REMOTE_ADDR"]
          addr
        end
      end

      def generate_cache_id(session_id)
        Digest::SHA1.hexdigest(
          session_id.to_s +
          env["HTTP_USER_AGENT"].to_s +
          remote_ip.to_s)
      end

      def cache_store
        @options[:cache_store]|| Rails.cache
      end

      def get_cached_entry(cache_id)
        if cache_id && cache_store.exist?(cache_id)
          cache_store.read(cache_id)
        end
      end

      def set_cookie_by_session_id(session_id)
        cache_id = generate_cache_id(session_id)
        env["HTTP_COOKIE"] = get_cached_entry(cache_id)
      end

      def session_key
        (@options[:session_id] || :session_id).to_s
      end

      def get_session_id_from_query(query)
        Rack::Utils.parse_query(query, "&")[session_key].to_s
      end

      def path_parameters
        env['action_dispatch.request.path_parameters'] || {}
      end

      def exclude_formats
        (%w{css js xml} + [@options[:exclude_formats]].flatten).compact.uniq
      end

      def page_warrants_cookie?
        !exclude_formats.include? path_parameters[:format].to_s
      end

      def cache_cookie_by_session_id(session_id, cookie)
        cache_store.write(generate_cache_id(session_id), cookie)
      end

      def convert_url(url, session_id)
        uri = URI.parse(URI.escape(url))
        if uri.scheme.empty? || uri.scheme.to_s =~ /http/
          query = Rack::Utils.parse_query(uri.query)
          uri.query = Rack::Utils.build_query(query.merge({session_key => session_id}))
        end
        uri.to_s
      end

      def fix_url(ref,session_id)
        if ref
          ref .replace convert_url(ref,session_id)
        end
      end

      def process_page?
        header["Content-Type"].to_s.downcase =~ /html/
      end

      def page_has_body?
        response.respond_to?(:body)
      end

      def content_is_arrayed?(content)
        return false unless content.is_a?(Array)
        return false if content.size == 0
        [ActionView::OutputBuffer, String].detect do |klass|
          content.is_a?(klass)
        end
      end

      def process_body(body, session_id)
        body_doc = Nokogiri::HTML(body)
        process_href(body_doc, session_id)
        process_form(body_doc, session_id)
        body.replace body_doc.to_html
      end

      def process_href(doc, session_id)
        doc.css("a").map do |a|
          fix_url(a["href"],session_id)
        end
      end

      def process_form(doc, session_id)
        doc.css("form").map do |form|
          if form["action"]
            fix_url(form["action"],session_id)
            form.add_child("<input type='hidden'  name='#{session_key}' value='#{session_id}'>")
          end
        end
      end
    end
  end
end
