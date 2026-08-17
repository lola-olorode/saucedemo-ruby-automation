# Centralized test data. saucedemo.com exposes a fixed set of demo
# accounts sharing one password — kept here instead of hardcoded in
# specs so there's a single place to update if that ever changes.

module TestData
  PASSWORD = "secret_sauce".freeze

  USERS = {
    standard: "standard_user",
    locked_out: "locked_out_user",
    problem: "problem_user",
    performance_glitch: "performance_glitch_user"
  }.freeze

  CHECKOUT_INFO = {
    first_name: "Funmilola",
    last_name: "Olorode",
    postal_code: "EC1A 1BB"
  }.freeze
end
