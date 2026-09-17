require_relative "../spec_helper"


RSpec.describe "Smoke sweep", :smoke do
  it "completes a full purchase journey" do
    Flows::AuthFlow.new(@driver).login_and_reach_inventory("standard")
    cart = Flows::ShoppingFlow.new(@driver).add_backpack_and_view_cart
    checkout = Flows::CheckoutFlow.new(@driver).complete_checkout(cart)

    expect(checkout.completion_header.downcase).to include("thank you")
  end
end
