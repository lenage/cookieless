require "spec_helper"

shared_examples "common" do
  context "Rails app" do
  background { Capybara.app = TestRailsApp::Application}
    scenario "test link" do
      page.visit '/'
      page.click_on "Link"
      page.should have_content "Session found"
    end
    scenario "test form" do
      page.visit '/'
      page.click_on "Submit"
      page.should have_content "Session found"
    end
  end
end

feature "Cookieless" , %q{
  As a developer
  I want to run my app even if the user has his cookies disabled
} do
  context "with cookies" do
    include_examples "common"
  end
  context "with cookies disabled" do
  background { Capybara.app = TestRailsApp::Application}
    background {page.disable_cookies(true)    }
    include_examples "common"
  end
end
