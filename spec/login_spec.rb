require_relative "spec_helper"

RSpec.describe "Login" do
  it "lands on the inventory page with valid credentials" do
    login_page = Pages::LoginPage.new(@driver).load
    login_page.login(TestData::USERS[:standard], TestData::PASSWORD)

    inventory_page = Pages::InventoryPage.new(@driver)
    expect(inventory_page.loaded?).to be true
  end

  it "blocks a locked-out user" do
    login_page = Pages::LoginPage.new(@driver).load
    login_page.login(TestData::USERS[:locked_out], TestData::PASSWORD)

    expect(login_page.error?).to be true
    expect(login_page.error_message.downcase).to include("locked out")
  end

  [
    { username: "", password: "", expected_fragment: "username is required" },
    { username: TestData::USERS[:standard], password: "", expected_fragment: "password is required" },
    { username: "not_a_real_user", password: "wrong_password", expected_fragment: "do not match" }
  ].each do |scenario|
    it "shows an error for invalid credentials: #{scenario[:expected_fragment]}" do
      login_page = Pages::LoginPage.new(@driver).load
      login_page.login(scenario[:username], scenario[:password])

      expect(login_page.error?).to be true
      expect(login_page.error_message.downcase).to include(scenario[:expected_fragment])
    end
  end
end
