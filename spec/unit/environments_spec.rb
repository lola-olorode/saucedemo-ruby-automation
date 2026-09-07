require_relative "../spec_helper"

RSpec.describe Environments do
  around do |example|
    original = ENV.fetch("TEST_ENV", nil)
    example.run
    ENV["TEST_ENV"] = original
  end

  it "defaults to prod when TEST_ENV is unset" do
    ENV.delete("TEST_ENV")
    expect(described_class.current[:base_url]).to eq("https://www.saucedemo.com/")
  end

  it "returns the staging config when TEST_ENV=staging" do
    ENV["TEST_ENV"] = "staging"
    expect(described_class.current[:default_timeout]).to eq(15)
  end

  it "raises a clear error for an unknown environment" do
    ENV["TEST_ENV"] = "not_a_real_env"
    expect { described_class.current }.to raise_error(ArgumentError, /Unknown TEST_ENV/)
  end
end
