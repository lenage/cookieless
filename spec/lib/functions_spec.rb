require_relative"../../lib/cookieless/functions"

class TestFunctions
  include Rack::Cookieless::Functions
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

class TestStore
  attr_accessor :store
  def initialize
    @store = {}
  end

  def exist?(id)
    @store.include?(id)
  end

  def read(id)
    @store[id]
  end

  def write(id,val)
    @store[id]=val
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
  end
end
