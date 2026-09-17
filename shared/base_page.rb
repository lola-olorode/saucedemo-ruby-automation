require "selenium-webdriver"

module Pages
  class BasePage
    DEFAULT_TIMEOUT = 10

    attr_reader :driver

    def initialize(driver)
      @driver = driver
      @wait = Selenium::WebDriver::Wait.new(timeout: DEFAULT_TIMEOUT)
    end

    def visit(url)
      driver.get(url)
      self
    end

    def find(locator)
      @wait.until { driver.find_element(*locator).displayed? && driver.find_element(*locator) }
      driver.find_element(*locator)
    end

    def find_all(locator)
      @wait.until { driver.find_elements(*locator).any? }
      driver.find_elements(*locator)
    end

    def click(locator)
      @wait.until { driver.find_element(*locator).enabled? }
      el = driver.find_element(*locator)

      driver.execute_script(<<~JS, el)
        arguments[0].__wd_clicked = false;
        arguments[0].addEventListener("click", function () {
          this.__wd_clicked = true;
        }, { once: true });
      JS

      el.click
      registered = click_registered?(el)
      driver.execute_script("arguments[0].click();", el) unless registered
      self
    end

    def type_text(locator, text)
      el = find(locator)
      el.clear
      el.send_keys(text)
      return self if driver.execute_script("return arguments[0].value;", el) == text

      driver.execute_script(<<~JS, el, text)
        var input = arguments[0];
        var value = arguments[1];
        var setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set;
        setter.call(input, value);
        input.dispatchEvent(new Event("input", { bubbles: true }));
        input.dispatchEvent(new Event("change", { bubbles: true }));
      JS
      self
    end

    def text_of(locator)
      find(locator).text
    end

    def visible?(locator, timeout: DEFAULT_TIMEOUT)
      Selenium::WebDriver::Wait.new(timeout: timeout).until { driver.find_element(*locator).displayed? }
      true
    rescue Selenium::WebDriver::Error::TimeoutError, Selenium::WebDriver::Error::NoSuchElementError
      false
    end

    def select_by_value(locator, value)
      Selenium::WebDriver::Support::Select.new(find(locator)).select_by(:value, value)
      self
    end

    private

    def click_registered?(el)
      driver.execute_script("return !!arguments[0].__wd_clicked;", el)
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      true
    end
  end
end
