require_relative "../shared/base_flow"
require_relative "../pages/login_page"
require_relative "../pages/inventory_page"
require_relative "../dataloader/user_loader"

module Flows
  class AuthFlow < Shared::BaseFlow
    def login_as(user_key = "standard")
      step("Log in as fixture user '#{user_key}'")
      user = Dataloader::UserLoader.get_user(user_key)

      login_page = Pages::LoginPage.new(driver)
      login_page.load
      login_page.login(user[:username], user[:password])
      login_page
    end

    def login_and_reach_inventory(user_key = "standard")
      login_as(user_key)
      inventory_page = Pages::InventoryPage.new(driver)
      inventory_page.loaded?
      inventory_page
    end
  end
end
