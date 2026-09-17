# Environment configuration layer.
#
# Lets the same suite target different environments without touching spec

module Environments
  CONFIGS = {
    "prod" => {
      base_url: "https://www.saucedemo.com/",
      default_timeout: 10
    },
    "staging" => {
      base_url: "https://www.saucedemo.com/",
      default_timeout: 15 # staging environments are often slower
    }
  }.freeze

  def self.current
    env_name = ENV.fetch("TEST_ENV", "prod")
    CONFIGS.fetch(env_name) do
      raise ArgumentError, "Unknown TEST_ENV '#{env_name}'. Valid options: #{CONFIGS.keys}"
    end
  end
end
