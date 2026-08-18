require_relative "../spec_helper"

RSpec.describe "Cart and Checkout" do
  it "removes an item from the cart" do
    cart = Flows::ShoppingFlow.new(logged_in_driver).add_backpack_and_view_cart
    expect(cart.item_count).to eq(1)

    cart.remove_backpack
    expect(cart.item_count).to eq(0)
  end

  it "completes the full checkout happy path" do
    cart = Flows::ShoppingFlow.new(logged_in_driver).add_backpack_and_view_cart
    checkout = Flows::CheckoutFlow.new(@driver).complete_checkout(cart)

    expect(checkout.completion_header.downcase).to include("thank you")
  end

  it "requires a first name to proceed through checkout" do
    cart = Flows::ShoppingFlow.new(logged_in_driver).add_backpack_and_view_cart
    cart.checkout

    checkout = Pages::CheckoutPage.new(@driver)
    info = Dataloader::CheckoutDataLoader.load_checkout_info("default")
    checkout.fill_information(first_name: "", last_name: info[:last_name], postal_code: info[:postal_code])

    expect(checkout.error_message.downcase).to include("first name is required")
  end
end
