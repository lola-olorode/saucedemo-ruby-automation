require "selenium-webdriver"
require_relative "../lib/pages/login_page"
require_relative "../lib/pages/inventory_page"
require_relative "../lib/pages/cart_page"
require_relative "../lib/pages/checkout_page"
require_relative "../lib/support/logger"
require_relative "../lib/support/screenshot"
require_relative "../config/test_data"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.example_status_persistence_file_path = "reports/.rspec_status"
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?

  logger = Support::TestLogger.instance

  config.before(:each) do
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless=new") unless ENV["HEADED"] == "1"
    options.add_argument("--window-size=1400,1000")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    logger.info("Starting browser | env=#{ENV.fetch('TEST_ENV', 'prod')}")
    @driver = Selenium::WebDriver.for(:chrome, options: options)
  end

  config.after(:each) do |example|
    if example.exception
      path = Support::Screenshot.capture(@driver, example.full_description)
      logger.error("FAILED: #{example.full_description} | screenshot: #{path}")
    end
    logger.info("Quitting browser")
    @driver&.quit
  end

  # Helper available in every spec: returns a driver already logged in
  # as the standard user, landed on the inventory page. Saves every
  # spec that needs an authenticated session from repeating the login
  # steps.
  config.include(Module.new do
    def logged_in_driver
      login_page = Pages::LoginPage.new(@driver)
      login_page.load
      login_page.login(TestData::USERS[:standard], TestData::PASSWORD)
      Pages::InventoryPage.new(@driver).loaded?
      @driver
    end
  end)
end
