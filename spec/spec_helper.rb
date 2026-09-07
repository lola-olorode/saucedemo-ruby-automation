require "selenium-webdriver"
require_relative "../lib/pages/login_page"
require_relative "../lib/pages/inventory_page"
require_relative "../lib/pages/cart_page"
require_relative "../lib/pages/checkout_page"
require_relative "../lib/shared/utils/logger"
require_relative "../lib/shared/utils/screenshot"
require_relative "../lib/flows/auth_flow"
require_relative "../lib/flows/shopping_flow"
require_relative "../lib/flows/checkout_flow"
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

  # spec/core and spec/sweeps drive a real browser; spec/unit exercises
  # framework logic (environments, dataloaders) in isolation and has no
  # business paying for a Chrome launch on every example.
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

  # Helper available in every spec: returns a driver already logged in
  # as the standard fixture user, landed on the inventory page — via
  # AuthFlow, so the login journey lives in one place instead of being
  # repeated across specs.
  config.include(Module.new do
    def logged_in_driver
      Flows::AuthFlow.new(@driver).login_and_reach_inventory("standard")
      @driver
    end
  end)
end
