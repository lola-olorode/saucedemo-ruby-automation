# SauceDemo Test Automation Framework (Ruby)

A Selenium + RSpec UI automation suite for [saucedemo.com](https://www.saucedemo.com/),
built with the **Page Object Model (POM)** — the same stack and pattern
(Ruby, RSpec, Selenium, POM) used in my day-to-day work, applied here to a
public site so the approach is fully shareable.

A parallel [Python/pytest version](../saucedemo-automation) of this same
site exists in this account too — built to demonstrate stack versatility,
since most QA teams use one or the other.

## Architecture

```
saucedemo-ruby/
├── lib/
│   ├── pages/                # Page Object Model — one class per screen
│   │   ├── base_page.rb       # Shared wait/interaction helpers
│   │   ├── login_page.rb
│   │   ├── inventory_page.rb
│   │   ├── cart_page.rb
│   │   └── checkout_page.rb
│   └── support/
│       ├── logger.rb          # Run-scoped file + console logging
│       └── screenshot.rb      # Screenshot-on-failure capture
├── spec/
│   ├── spec_helper.rb          # Driver lifecycle, logged-in helper, failure hook
│   ├── login_spec.rb
│   ├── inventory_spec.rb
│   └── cart_checkout_spec.rb
├── config/
│   ├── environments.rb         # dev/staging/prod-style env layering
│   └── test_data.rb            # Accounts, checkout data
├── .github/workflows/           # CI: runs the suite on every push
├── Gemfile
├── Rakefile
└── .rspec
```

**Design decisions:**
- **Page Object Model** — locators and interactions live in `lib/pages/`,
  so a UI change means updating one file, not every spec.
- **`config.before/after(:each)`** in `spec_helper.rb` handles browser
  lifecycle centrally, including a `logged_in_driver` helper available in
  every spec, so specs needing an authenticated session don't repeat login
  steps.
- **Environment layering** — `config/environments.rb` selects base URL
  and timeout via `TEST_ENV`, so the same suite can target different
  deployments without touching spec code.
- **Structured logging + screenshot-on-failure** — every run writes a
  timestamped log file, and any failing spec automatically captures a
  screenshot via the `after(:each)` hook — the first thing worth checking
  when a CI build goes red.
- **CI-first** — GitHub Actions runs the full suite headless on every push
  and uploads logs/screenshots/JUnit results as build artifacts.

## Coverage

| Area | Scenarios |
|---|---|
| Login | Valid login, locked-out user, empty/invalid credentials |
| Inventory | Sort by price (asc/desc), sort by name, add-to-cart badge count |
| Cart & Checkout | Remove item, full happy-path checkout, required-field validation |

## Running locally

```bash
bundle install
bundle exec rake spec        # full suite, headless by default
HEADED=1 bundle exec rspec    # watch it run in a visible browser
TEST_ENV=staging bundle exec rspec   # target a different environment
```

Reports land in `reports/` — logs, screenshots on failure, and a JUnit XML
result file for CI integration.

## Tech stack

Ruby · Selenium WebDriver · RSpec · GitHub Actions
