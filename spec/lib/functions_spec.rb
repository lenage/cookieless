require_relative"../../lib/cookieless/functions"
require "test_store"
class TestFunctions
  include Rack::Cookieless::Functions
  attr_accessor :response
  def initialize
    @env={}
    @options={}
  end

  def env
    @env
  end

  def options
    @options
  end

end

describe "Functions" do
  before do
    @testclass = TestFunctions.new
  end

  describe "#supports_cookies?" do
    it "should return true if  env has cookies" do
      @testclass.env["HTTP_COOKIE"]=true
      @testclass.supports_cookies?.should be true
    end
    it "should return false if  env has no cookies" do
      @testclass.supports_cookies?.should be false
    end
  end

  describe "#noconvert" do
    it "returns false if there is no noconvert set" do
      @testclass.noconvert.should be false
    end
    describe "with a proc" do
      it "returns true if the given proc returns true" do
        @testclass.options[:noconvert] = Proc.new { true }
        @testclass.noconvert.should be true
      end
      it "returns false if the given proc returns false" do
        @testclass.options[:noconvert] = Proc.new { false }
        @testclass.noconvert.should be false
      end
    end
  end

  describe "#get_session_id" do
    it "returns the session_id found in the query" do
      @testclass.options[:session_id] = :si
      @testclass.env["QUERY_STRING"] = "si=query"
      @testclass.get_session_id.should == "query"
    end
    it "returns the session_id found in the referrer" do
      @testclass.options[:session_id] = :si
      @testclass.env["HTTP_REFERER"] = "http://www.example.com?si=referer"
      @testclass.get_session_id.should == "referer"
    end
    it "returns the session_id found in the query of both are given" do
      @testclass.options[:session_id] = :si
      @testclass.env["HTTP_REFERER"] = "http://www.example.com?si=referer"
      @testclass.env["QUERY_STRING"] = "si=query"
      @testclass.get_session_id.should == "query"
    end
    it "handles referers with special characters" do
      @testclass.options[:session_id] = :si
      @testclass.env["HTTP_REFERER"] = "http://mysearch.avg.com/?cid={2FE739F5-7A80-4FA5-9B65-7ADE10D3ADFC}&mid=1b06ffb2836747d39d0b9d3bff774cdd-afd01f4fcd66c4f49bbc5334adc3c307cf96ffe9&lang=nl&ds=AVG&pr=fr&d=2013-05-10%2015:09:11&v=15.1.0.2&pid=safeguard&sg=2&sap=hp"
      @testclass.get_session_id.should == ""
    end
  end

  describe "#remote_ip" do
    it "returns the remote address if it is set" do
      @testclass.env["REMOTE_ADDR"] = "127.0.0.1"
      @testclass.remote_ip.should == "127.0.0.1"
    end
    it "returns the http_x_forwarded_for address if it is set" do
      @testclass.env["HTTP_X_FORWARDED_FOR"] = "127.0.0.1,127.0.0.2"
      @testclass.remote_ip.should == "127.0.0.1"
    end
    it "returns the http_x_forwarded_for address if both are set" do
      @testclass.env["REMOTE_ADDR"] = "127.0.0.6"
      @testclass.env["HTTP_X_FORWARDED_FOR"] = "127.0.0.1,127.0.0.2"
      @testclass.remote_ip.should == "127.0.0.1"
    end
  end

  describe "#generate_cache_id" do
    it "generates a cache id" do
      @testclass.env["HTTP_USER_AGENT"] = "007"
      @testclass.env["REMOTE_ADDR"] = "127.0.0.1"
      @testclass.generate_cache_id("key").should == "4bff0c13f4436feafd0f80c4ff4e7bc7a61c7eb3"
    end
  end

  describe "#cache_store" do
    it "returns the set  store" do
      testStore = TestStore.new
      @testclass.options[:cache_store] = testStore
      @testclass.cache_store.should == testStore
    end
  end

  describe "#get_cached_entry" do
    it "retrieves a cached entry from a store" do
      testStore = TestStore.new
      testStore.write(:stored, "I am cached")
      @testclass.options[:cache_store] = testStore
      @testclass.get_cached_entry(:stored).should == "I am cached"
    end
  end

  describe "#set_cookie_by_session_id" do
    it "stores the cookie in the environment" do
        @testclass.env["HTTP_USER_AGENT"] = "007"
        @testclass.env["REMOTE_ADDR"] = "127.0.0.1"
        testStore = TestStore.new
        testStore.write("4bff0c13f4436feafd0f80c4ff4e7bc7a61c7eb3", "I am cached")
        @testclass.options[:cache_store] = testStore
        @testclass.set_cookie_by_session_id("key")
        @testclass.env["HTTP_COOKIE"].should== "I am cached"
      end
      it "does nothing if the session_id is empty" do
        @testclass.set_cookie_by_session_id("")
        @testclass.env.keys.include?("HTTP_COOKIE").should be_false
      end
  end

  describe "#session_key" do
    it "returns 'session_id' as default" do
      @testclass.session_key.should == "session_id"
    end
    it "returns the 'session_id' set as option" do
      @testclass.options[:session_id] = "my_key"
      @testclass.session_key.should == "my_key"
    end
  end

  describe "#get_session_id_from_query" do
    it "parses the session value from a query string" do
      @testclass.get_session_id_from_query("l=en&session_id=test&q=10").should == "test"
    end
  end

  describe "#path_parameters"do
    it "returns the request.path_parameters if set" do
      @testclass.env['action_dispatch.request.path_parameters'] = "ok"
      @testclass.path_parameters.should == "ok"
    end
    it "returns an empty hash if there are none" do
      @testclass.path_parameters.should == {}
    end
  end

  describe "#exclude_formats" do
    it "returns a list of extensions" do
      @testclass.exclude_formats.size.should > 0
    end

    it "returns a given extension in the list" do
      @testclass.options[:exclude_formats]= "xslx"
      @testclass.exclude_formats.include?("xslx").should be true
    end

    it "given a list will add all of them" do
      @testclass.options[:exclude_formats]= %w{ xslx docx}
      @testclass.exclude_formats.include?("xslx").should be true
      @testclass.exclude_formats.include?("docx").should be true
    end
  end

  describe "#page_warrants_cookie?" do
    it "returns true if this is not an excluded page format" do
      @testclass.options[:exclude_formats]= %w{ xslx docx}
      @testclass.env['action_dispatch.request.path_parameters'] = {:action => "show", :format => "html"}
      @testclass.page_warrants_cookie?.should == true
    end
    it "returns false if this is an excluded page format" do
      @testclass.options[:exclude_formats]= %w{ xslx docx}
      @testclass.env['action_dispatch.request.path_parameters'] = {:action => "show", :format => "docx"}
      @testclass.page_warrants_cookie?.should == false
    end
  end

  describe "#cache_cookie_by_session_id" do
    it "stores the cookie in the cache" do
      testStore = TestStore.new
      @testclass.options[:cache_store] = testStore
      @testclass.cache_cookie_by_session_id("id", "my_cookie")
      testStore.store.size.should == 1
      testStore.store.first[1].should == "my_cookie"
    end
  end

  describe "#convert_url" do
    it "add the session to the querystring" do
      @testclass.fix_url("http://www.example.com", "1234").should == "http://www.example.com?session_id=1234"
    end
  end

  describe "#fix_url" do
    it "adds the session id, replacing the current value of the string" do
      url = "http://www.example.com"
      @testclass.fix_url(url, "1234")
      url.should == "http://www.example.com?session_id=1234"
    end
    it "returns nil of no url given" do
      @testclass.fix_url(nil, "").should be nil
    end
  end

  describe "#process_page?" do
    it "returns true for a html page" do
      header = {"Content-Type" => "text/html"}
      @testclass.process_page?(header).should == true
    end
    it "returns false for other content types" do
      header = {"Content-Type" => "application/pdf"}
      @testclass.process_page?(header).should == false
    end
  end

  describe "#unify_cookies" do
    it "mutiply set_cookies" do
      set_cookies = "__utmmobile=0xc9d7e6045084ceae; path=/; expires=Tue, 11-Nov-2014 15:18:57 GMT\n_site_session=BAh7DiIPZ; path=/; HttpOnly"
      @testclass.unify_cookies(set_cookies).should == "__utmmobile=0xc9d7e6045084ceae;_site_session=BAh7DiIPZ"
    end

    it "single set-cookies" do
      set_cookies = "__utmmobile=0xc9d7e6045084ceae; path=/; expires=Tue, 11-Nov-2014 15:18:57 GMT"
      @testclass.unify_cookies(set_cookies).should == "__utmmobile=0xc9d7e6045084ceae"
    end

  end

  describe "#page_has_body?" do
    it "checks if the page has a body" do
      content = mock(:content)
      content.stub! :body
      @testclass.page_has_body?(content).should be true
    end

    it "returns false if no body" do
      @testclass.page_has_body?(Object.new).should be false
    end
  end

  describe "#content_is_arrayed?" do
    it "returns false if not an array" do
      @testclass.content_is_arrayed?("").should be false
    end
    it "returns false if the array is empty" do
      @testclass.content_is_arrayed?([]).should be false
    end
    it "returns false if the first element is of the wrong type" do
      @testclass.content_is_arrayed?([5]).should be false
    end
    it "returns true if the first element is of the correct type" do
      @testclass.content_is_arrayed?(["test"]).should be true
    end
  end

  context "body processing" do
    before do
      @doc =<<EOF
<html>
<body>
<a href="http://www.example.com">link</a>
<form action="shop">
</form>
</body>
</html>
EOF
    @body_doc = Nokogiri::HTML(@doc)
    end

    describe "#process_href" do
      it "rewtrites the hrefs in the document adding our session key" do
        doc=@testclass.process_href(@body_doc,"1234")
        doc.to_html.include?("http://www.example.com?session_id=1234").should == true
      end
    end

    describe "#process_form" do
      it "adds a hidden field to the form" do
        doc=@testclass.process_form(@body_doc,"1234")
        doc.to_html.include?("<input type=\"hidden\" name=\"session_id\" value=\"1234\">").should == true
      end
    end
    describe "#process_body" do
      it "replaces the necessary references by adding our session key" do
        @testclass.process_body(@doc,"1234")
        @doc.include?("http://www.example.com?session_id=1234").should == true
        @doc.include?("<input type=\"hidden\" name=\"session_id\" value=\"1234\">").should == true
      end
    end
  end
end
