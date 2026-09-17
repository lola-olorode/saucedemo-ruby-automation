require_relative "../shared/base_page"

module Pages
  class InventoryPage < BasePage
    PAGE_TITLE = [:class, "title"].freeze
    SORT_DROPDOWN = [:class, "product_sort_container"].freeze
    ITEM_NAME = [:class, "inventory_item_name"].freeze
    ITEM_PRICE = [:class, "inventory_item_price"].freeze
    CART_BADGE = [:class, "shopping_cart_badge"].freeze
    CART_LINK = [:class, "shopping_cart_link"].freeze
    ADD_BACKPACK = [:id, "add-to-cart-sauce-labs-backpack"].freeze

    def loaded?
      visible?(PAGE_TITLE, timeout: 6)
    end

    def sort_by(value)
      select_by_value(SORT_DROPDOWN, value)
      self
    end

    def item_names
      find_all(ITEM_NAME).map(&:text)
    end

    def item_prices
      find_all(ITEM_PRICE).map { |el| el.text.delete("$").to_f }
    end

    def add_backpack_to_cart
      click(ADD_BACKPACK)
      self
    end

    def cart_count
      visible?(CART_BADGE, timeout: 3) ? text_of(CART_BADGE).to_i : 0
    end

    def go_to_cart
      click(CART_LINK)
      self
    end
  end
end
