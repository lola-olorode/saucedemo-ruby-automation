require_relative "utils/logger"

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
