require_relative "../spec_helper"

# A full end-to-end journey through the app in one spec — login through
# to order confirmation — run on every commit as a fast "is anything
# fundamentally broken" gate, distinct from the feature-level specs in
# spec/core/ which check individual behaviors in isolation.
RSpec.describe "Smoke sweep", :smoke do
  it "completes a full purchase journey" do
    Flows::AuthFlow.new(@driver).login_and_reach_inventory("standard")
    cart = Flows::ShoppingFlow.new(@driver).add_backpack_and_view_cart
    checkout = Flows::CheckoutFlow.new(@driver).complete_checkout(cart)

    expect(checkout.completion_header.downcase).to include("thank you")
  end
end
