require "selenium-webdriver"

module Pages
  # All page objects inherit from this. Centralizes the Selenium
  # wait/interaction logic so individual page classes stay declarative
  # (locators + actions) instead of repeating boilerplate wait code.
  class BasePage
    DEFAULT_TIMEOUT = 10

    attr_reader :driver

    def initialize(driver)
      @driver = driver
      @wait = Selenium::WebDriver::Wait.new(timeout: DEFAULT_TIMEOUT)
    end

    def open(url)
      driver.get(url)
      self
    end

    def find(locator)
      @wait.until { driver.find_element(locator).displayed? && driver.find_element(locator) }
      driver.find_element(locator)
    end

    def find_all(locator)
      @wait.until { driver.find_elements(locator).any? }
      driver.find_elements(locator)
    end

    def click(locator)
      @wait.until { driver.find_element(locator).enabled? }
      driver.find_element(locator).click
      self
    end

    def type_text(locator, text)
      el = find(locator)
      el.clear
      el.send_keys(text)
      self
    end

    def text_of(locator)
      find(locator).text
    end

    def visible?(locator, timeout: DEFAULT_TIMEOUT)
      Selenium::WebDriver::Wait.new(timeout: timeout).until { driver.find_element(locator).displayed? }
      true
    rescue Selenium::WebDriver::Error::TimeoutError, Selenium::WebDriver::Error::NoSuchElementError
      false
    end

    def select_by_value(locator, value)
      Selenium::WebDriver::Support::Select.new(find(locator)).select_by(:value, value)
      self
    end
  end
end
