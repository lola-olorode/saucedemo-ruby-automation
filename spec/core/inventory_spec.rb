require_relative "../spec_helper"

RSpec.describe "Inventory" do
  it "sorts by price low to high" do
    page = Pages::InventoryPage.new(logged_in_driver)
    page.sort_by("lohi")

    prices = page.item_prices
    expect(prices).to eq(prices.sort)
  end

  it "sorts by price high to low" do
    page = Pages::InventoryPage.new(logged_in_driver)
    page.sort_by("hilo")

    prices = page.item_prices
    expect(prices).to eq(prices.sort.reverse)
  end

  it "sorts by name A to Z" do
    page = Pages::InventoryPage.new(logged_in_driver)
    page.sort_by("az")

    names = page.item_names
    expect(names).to eq(names.sort)
  end

  it "updates the cart badge when an item is added" do
    page = Pages::InventoryPage.new(logged_in_driver)
    expect(page.cart_count).to eq(0)

    page.add_backpack_to_cart

    expect(page.cart_count).to eq(1)
  end
end
