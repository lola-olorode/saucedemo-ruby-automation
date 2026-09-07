require_relative "../spec_helper"

# Broader than the smoke sweep — exercises the purchase journey across
# multiple fixture accounts, the kind of thing run before a release
# rather than on every commit.
RSpec.describe "Regression sweep", :regression do
  %w[standard performance_glitch].each do |user_key|
    it "completes a full purchase journey as '#{user_key}'" do
      Flows::AuthFlow.new(@driver).login_and_reach_inventory(user_key)
      cart = Flows::ShoppingFlow.new(@driver).add_backpack_and_view_cart
      checkout = Flows::CheckoutFlow.new(@driver).complete_checkout(cart)

      expect(checkout.completion_header.downcase).to include("thank you")
    end
  end
end
