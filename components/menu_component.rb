require_relative "../shared/base_page"

module Components
  class MenuComponent < Pages::BasePage
    MENU_BUTTON = [:id, "react-burger-menu-btn"].freeze
    CLOSE_BUTTON = [:id, "react-burger-cross-btn"].freeze
    LOGOUT_LINK = [:id, "logout_sidebar_link"].freeze
    RESET_APP_STATE_LINK = [:id, "reset_sidebar_link"].freeze

    def open_menu
      click(MENU_BUTTON)
      self
    end

    def close_menu
      click(CLOSE_BUTTON)
      self
    end

    def logout
      open_menu
      click(LOGOUT_LINK)
      self
    end

    def reset_app_state
      open_menu
      click(RESET_APP_STATE_LINK)
      close_menu
      self
    end
  end
end
