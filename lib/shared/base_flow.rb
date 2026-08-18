require_relative "utils/logger"

# A "flow" sits above the page layer: it orchestrates several page
# objects into one business journey (e.g. "log in and land on
# inventory"). Specs call flows for journeys and call pages directly
# only for single-screen assertions.
module Shared
  class BaseFlow
    attr_reader :driver

    def initialize(driver)
      @driver = driver
      @log = Support::TestLogger.instance
    end

    def step(description)
      @log.info("STEP: #{description}")
    end
  end
end
