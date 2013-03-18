require "spec_helper"

feature "Cookieless" , %q{
  As a developer
  I want to run my app even if the user has his cookies disabled
} do
  background { Capybara.app = TestRailsApp::Application}
  scenario "with cookies enable" do
    page.visit '/'
    page.click_on "Link"
    page.should have_content "Session found"
  end
  scenario "with cookies disabled" do
    page.disable_cookies(true)
    page.visit '/'
    page.click_on "Link"
    page.should have_content "Session found"
  end
end
