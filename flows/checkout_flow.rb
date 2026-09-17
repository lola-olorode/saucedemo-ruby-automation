require_relative "../shared/base_flow"
require_relative "../pages/checkout_page"
require_relative "../dataloader/checkout_data_loader"

module Flows
  class CheckoutFlow < Shared::BaseFlow
    def complete_checkout(cart_page, info_key = "default")
      step("Complete checkout from an already-populated cart")
      cart_page.checkout

      checkout_page = Pages::CheckoutPage.new(driver)
      info = Dataloader::CheckoutDataLoader.load_checkout_info(info_key)
      checkout_page.fill_information(
        first_name: info[:first_name],
        last_name: info[:last_name],
        postal_code: info[:postal_code]
      )
      checkout_page.finish
      checkout_page
    end
  end
end
