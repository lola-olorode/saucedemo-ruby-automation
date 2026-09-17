require "fileutils"

module Support
  # Captures a screenshot the moment a spec fails and saves it to reports/screenshots/
  module Screenshot
    DIR = "reports/screenshots".freeze

    def self.capture(driver, example_description)
      FileUtils.mkdir_p(DIR)
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      safe_name = example_description.gsub(/[^0-9A-Za-z]/, "_")
      path = File.join(DIR, "#{safe_name}_#{timestamp}.png")
      driver.save_screenshot(path)
      path
    end
  end
end
