require "json"

module Dataloader
  class CheckoutDataLoader
    FIXTURE_PATH = File.join(__dir__, "fixtures", "checkout_info.json")

    def self.load_checkout_info(key = "default")
      data = JSON.parse(File.read(FIXTURE_PATH), symbolize_names: true)
      data.fetch(key.to_sym) do
        raise KeyError, "No fixture checkout info named '#{key}'. Available: #{data.keys}"
      end
    end
  end
end
