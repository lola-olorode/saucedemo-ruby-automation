require_relative "../shared/base_flow"
require_relative "../pages/inventory_page"
require_relative "../pages/cart_page"

module Flows
  class ShoppingFlow < Shared::BaseFlow
    def add_backpack_and_view_cart
      step("Add backpack to cart and navigate to cart page")
      inventory_page = Pages::InventoryPage.new(driver)
      inventory_page.add_backpack_to_cart
      inventory_page.go_to_cart
      Pages::CartPage.new(driver)
    end

    def sort_inventory(sort_value)
      step("Sort inventory by '#{sort_value}'")
      Pages::InventoryPage.new(driver).sort_by(sort_value)
    end
  end
end
