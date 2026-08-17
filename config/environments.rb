# Environment configuration layer.
#
# Lets the same suite target different environments without touching spec
# code — set ENV["TEST_ENV"] and the base URL / timeout switch with it.
# saucedemo.com only exposes one public target, so "staging" here points
# at the same host — on a real project each key would point at a
# genuinely different deployment.

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
