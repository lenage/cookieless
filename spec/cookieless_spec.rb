require "spec_helper"

feature "Cookieless" , %q{
  As a developer
  I want to run my app even if the user has his cookies disabled
} do
  background { Capybara.app = TestRailsApp::Application}
  scenario "with cookies enable" do
    page.visit '/'
    page.should have_content "Cookie found"
  end
end
