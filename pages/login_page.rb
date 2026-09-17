require_relative "../shared/base_page"
require_relative "../shared/environments"

module Pages
  class LoginPage < BasePage
    USERNAME_INPUT = [:id, "user-name"].freeze
    PASSWORD_INPUT = [:id, "password"].freeze
    LOGIN_BUTTON = [:id, "login-button"].freeze
    ERROR_MESSAGE = [:css, "[data-test='error']"].freeze

    def load
      visit(Environments.current[:base_url])
    end

    def login(username, password)
      type_text(USERNAME_INPUT, username)
      type_text(PASSWORD_INPUT, password)
      click(LOGIN_BUTTON)
      self
    end

    def error_message
      text_of(ERROR_MESSAGE)
    end

    def error?
      visible?(ERROR_MESSAGE, timeout: 4)
    end
  end
end
