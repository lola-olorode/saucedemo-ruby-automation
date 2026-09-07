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

    # Named `visit`, not `open`, so a bare call inside a page object can't
    # be misread as (or accidentally shadow) Kernel#open.
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

    # A plain WebDriver click occasionally lands on the element (confirmed
    # by coordinates and `elementFromPoint`) but never actually fires the
    # page's click handler — observed against saucedemo.com's "Add to
    # cart" buttons on current Chrome/W3C Actions. Rather than switch
    # every click to a JS-dispatched one (which can "click" things a real
    # user couldn't, e.g. a covered or disabled element), this instruments
    # the element with a one-shot listener, does the normal native click,
    # and only falls back to a JS click if the native one demonstrably
    # never reached the element.
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

    # Same class of problem as #click, on the input side: native send_keys
    # occasionally leaves a React-controlled field's DOM value unchanged
    # (observed on the checkout form) even though no error is raised. This
    # verifies the value actually landed and, if not, sets it through
    # React's own native input setter plus a real "input"/"change" event —
    # the standard way to update a React-controlled field from outside
    # React — so the app's own state updates exactly as it would for a
    # user typing.
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

    # If the click legitimately navigated or re-rendered the page, `el`
    # may already be detached by the time we check it — that's evidence
    # the click worked, not that it failed, so treat it as a success
    # rather than firing a redundant (possibly double-submitting) JS click.
    def click_registered?(el)
      driver.execute_script("return !!arguments[0].__wd_clicked;", el)
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      true
    end
  end
end
