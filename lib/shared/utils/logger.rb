require "logger"
require "fileutils"

module Support
  # Wraps Ruby's Logger so every run writes a timestamped file
  # (reports/logs/) in addition to console output — useful for
  # debugging CI failures after the fact.
  class TestLogger
    LOG_DIR = "reports/logs".freeze

    def self.instance
      @instance ||= build_logger
    end

    def self.build_logger
      FileUtils.mkdir_p(LOG_DIR)
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      log_file = File.join(LOG_DIR, "run_#{timestamp}.log")

      logger = Logger.new(MultiIO.new($stdout, File.open(log_file, "a")))
      logger.level = Logger::DEBUG
      logger.formatter = proc do |severity, datetime, _progname, msg|
        "#{datetime.strftime('%H:%M:%S')} | #{severity.ljust(5)} | #{msg}\n"
      end
      logger
    end
  end

  # Small helper so the logger can write to both stdout and a file
  # without pulling in an extra gem.
  class MultiIO
    def initialize(*targets)
      @targets = targets
    end

    def write(*args)
      @targets.each { |t| t.write(*args) }
    end

    def close
      @targets.each(&:close)
    end
  end
end
