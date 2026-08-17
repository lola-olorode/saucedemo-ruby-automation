require_relative "spec_helper"

RSpec.describe "Cart and Checkout" do
  it "removes an item from the cart" do
    inventory = Pages::InventoryPage.new(logged_in_driver)
    inventory.add_backpack_to_cart
    inventory.go_to_cart

    cart = Pages::CartPage.new(@driver)
    expect(cart.item_count).to eq(1)

    cart.remove_backpack
    expect(cart.item_count).to eq(0)
  end

  it "completes the full checkout happy path" do
    inventory = Pages::InventoryPage.new(logged_in_driver)
    inventory.add_backpack_to_cart
    inventory.go_to_cart

    cart = Pages::CartPage.new(@driver)
    cart.checkout

    checkout = Pages::CheckoutPage.new(@driver)
    checkout.fill_information(**TestData::CHECKOUT_INFO)

    expect(checkout.summary_total).to include("$")

    checkout.finish
    expect(checkout.completion_header.downcase).to include("thank you")
  end

  it "requires a first name to proceed through checkout" do
    inventory = Pages::InventoryPage.new(logged_in_driver)
    inventory.add_backpack_to_cart
    inventory.go_to_cart

    Pages::CartPage.new(@driver).checkout

    checkout = Pages::CheckoutPage.new(@driver)
    checkout.fill_information(first_name: "", last_name: "Olorode", postal_code: "EC1A 1BB")

    expect(checkout.error_message.downcase).to include("first name is required")
  end
end
