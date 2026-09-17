source "https://rubygems.org"

gem "dotenv", "~> 3.1"
gem "httparty", "~> 0.21"
# httparty's JSON parser still calls JSON.parse with the removed `quirks_mode`
# keyword; pin below the json 3.0 release that dropped it until httparty ships a fix.
gem "json", "< 3"
gem "rake", "~> 13.2"
gem "rspec", "~> 3.13"
gem "rspec_junit_formatter", "~> 0.6"
gem "selenium-webdriver", "~> 4.24"

group :development do
  gem "rubocop", "~> 1.65", require: false
  gem "rubocop-rspec", "~> 3.0", require: false
end
