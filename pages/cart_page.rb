require_relative "../shared/base_page"

module Pages
  class CartPage < BasePage
    CART_ITEM = [:class, "cart_item"].freeze
    REMOVE_BACKPACK = [:id, "remove-sauce-labs-backpack"].freeze
    CHECKOUT_BUTTON = [:id, "checkout"].freeze

    def item_count
      find_all(CART_ITEM).size
    rescue Selenium::WebDriver::Error::TimeoutError
      0
    end

    def remove_backpack
      click(REMOVE_BACKPACK)
      self
    end

    def checkout
      click(CHECKOUT_BUTTON)
      self
    end
  end
end
