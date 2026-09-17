require "selenium-webdriver"
require_relative "../pages/login_page"
require_relative "../pages/inventory_page"
require_relative "../pages/cart_page"
require_relative "../pages/checkout_page"
require_relative "../shared/utils/logger"
require_relative "../shared/utils/screenshot"
require_relative "../flows/auth_flow"
require_relative "../flows/shopping_flow"
require_relative "../flows/checkout_flow"
require_relative "../dataloader/user_loader"
require_relative "../dataloader/checkout_data_loader"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.example_status_persistence_file_path = "reports/.rspec_status"
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?

  logger = Support::TestLogger.instance


  config.define_derived_metadata(file_path: %r{/spec/(core|sweeps)/}) do |metadata|
    metadata[:type] = :feature
  end

  config.before(:each, type: :feature) do
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless=new") unless ENV["HEADED"] == "1"
    options.add_argument("--window-size=1400,1000")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    logger.info("Starting browser | env=#{ENV.fetch('TEST_ENV', 'prod')}")
    @driver = Selenium::WebDriver.for(:chrome, options: options)
  end

  config.after(:each, type: :feature) do |example|
    if example.exception
      path = Support::Screenshot.capture(@driver, example.full_description)
      logger.error("FAILED: #{example.full_description} | screenshot: #{path}")
    end
    logger.info("Quitting browser")
    @driver&.quit
  end

  config.include(Module.new do
    def logged_in_driver
      Flows::AuthFlow.new(@driver).login_and_reach_inventory("standard")
      @driver
    end
  end)
end
