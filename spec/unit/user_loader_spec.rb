require_relative "../spec_helper"

RSpec.describe Dataloader::UserLoader do
  it "loads a known fixture user by key" do
    user = described_class.get_user("standard")
    expect(user).to include(username: "standard_user", password: "secret_sauce")
  end

  it "raises a clear error for an unknown fixture key" do
    expect { described_class.get_user("nonexistent") }
      .to raise_error(KeyError, /No fixture user named 'nonexistent'/)
  end
end
