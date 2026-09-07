# SauceDemo Test Automation Framework (Ruby)

A Selenium + RSpec UI automation suite for [saucedemo.com](https://www.saucedemo.com/),
structured as a layered framework — the same architectural pattern I use
in my day-to-day work (Ruby, RSpec, Selenium), applied here to a public
site so the approach is fully shareable.

A parallel [Python/pytest version](https://github.com/lola-olorode/saucedemo-portfolio) of this same
site exists too, using the same layered structure — built to demonstrate
stack versatility.

## Architecture

```
saucedemo-ruby/
├── lib/
│   ├── components/           # Reusable widgets shared across multiple pages
│   │   └── menu_component.rb  # The burger menu appears on every logged-in screen
│   ├── flows/                 # Business-journey layer: orchestrates pages into a task
│   │   ├── auth_flow.rb        # Login journeys
│   │   ├── shopping_flow.rb    # Sort / add-to-cart journeys
│   │   └── checkout_flow.rb    # Full checkout journey
│   ├── pages/                 # Page Object Model — one class per screen
│   │   ├── login_page.rb
│   │   ├── inventory_page.rb
│   │   ├── cart_page.rb
│   │   └── checkout_page.rb
│   └── shared/
│       ├── base_page.rb        # Shared wait/interaction helpers for every page
│       ├── base_flow.rb        # Shared step-logging for every flow
│       ├── environments.rb     # dev/staging/prod-style env layering
│       └── utils/
│           ├── logger.rb        # Run-scoped file + console logging
│           └── screenshot.rb    # Screenshot-on-failure capture
├── dataloader/                # Test data as data, not hardcoded in specs
│   ├── fixtures/
│   │   ├── users.json
│   │   └── checkout_info.json
│   ├── user_loader.rb
│   └── checkout_data_loader.rb
├── spec/
│   ├── spec_helper.rb           # Driver lifecycle, logged-in helper, failure hook
│   ├── core/                     # Feature-level specs, one file per screen/feature
│   ├── sweeps/                    # Full-journey smoke + regression sweeps
│   └── unit/                      # Framework logic specs (no browser)
├── .github/workflows/            # CI: RuboCop, then the suite, on every push
├── .rubocop.yml                  # Lint rules (annotated where they diverge from defaults)
├── Gemfile
├── Rakefile
└── .rspec
```

**Why layered like this:**
- **`pages/`** know how to interact with one screen. They don't know
  *why* — that's a level up.
- **`flows/`** know the business journey — "log in", "buy something" —
  by composing multiple page objects. A spec that needs "add an item and
  check out" calls one flow method instead of repeating four page-object
  calls; if the checkout journey changes, one flow file changes, not
  every spec that touches checkout.
- **`components/`** hold UI pieces reused across many pages (here, the
  burger menu), so a shared element's locators live in exactly one place.
- **`shared/`** holds cross-cutting concerns every page/flow needs
  (waits, logging, environment config) — nothing feature-specific.
- **`dataloader/`** treats test data as data: fixtures live in JSON,
  loader classes read them. Adding a new test account means editing a
  fixture file, not code.
- **`spec/core/`** covers individual features and edge cases in
  isolation; **`spec/sweeps/`** covers full end-to-end journeys — smoke
  (fast, every commit) and regression (broader, pre-release) — kept
  separate because they serve different purposes and run at different
  times in a CI pipeline. **`spec/unit/`** tests framework logic
  (environment selection, fixture loading) directly, with no browser
  involved — `spec_helper.rb` only spins up Chrome for specs under
  `core/` and `sweeps/`, so unit specs stay fast.

## Reliability notes

`BasePage#click` and `#type_text` verify that a native Selenium action
actually reached the page (a listener confirms the click fired; the
input's DOM value is checked after typing) before falling back to a
JS-dispatched equivalent — some of saucedemo.com's React-controlled
elements silently don't respond to plain WebDriver clicks/`send_keys` on
current Chrome. Native interaction is always tried first so specs still
exercise real browser input by default; the fallback only fires when
that demonstrably didn't work, rather than switching every interaction
to JS and losing that realism everywhere.

## Coverage

| Area | Scenarios |
|---|---|
| Login (core) | Valid login, locked-out user, empty/invalid credentials |
| Inventory (core) | Sort by price (asc/desc), sort by name, add-to-cart badge count |
| Cart & Checkout (core) | Remove item, full happy-path checkout, required-field validation |
| Smoke sweep | One full login → shop → checkout journey |
| Regression sweep | Full journey repeated across multiple fixture accounts |

## Running locally

```bash
bundle install
bundle exec rubocop                  # lint
bundle exec rake spec              # full suite — headless by default, no browser window appears
bundle exec rake unit                # framework-logic specs only, no browser
bundle exec rspec spec/sweeps        # full-journey sweeps only
HEADED=1 bundle exec rspec spec/core  # watch it happen in a real Chrome window
TEST_ENV=staging bundle exec rspec     # target a different environment
```

**Windows / PowerShell** (e.g. VS Code's integrated terminal) needs env
vars set as a separate statement rather than prefixed on the command line:

```powershell
bundle install
bundle exec rubocop
bundle exec rake spec

$env:HEADED = "1"
bundle exec rspec spec/core          # watch it happen in a real Chrome window

$env:TEST_ENV = "staging"
bundle exec rspec                     # target a different environment
```

`$env:HEADED` stays set for the rest of that terminal session — open a new
terminal, or run `Remove-Item Env:HEADED`, to go back to headless.

Reports land in `reports/` — logs, screenshots on failure, and a JUnit XML
result file for CI integration.

## Tech stack

Ruby · Selenium WebDriver · RSpec · RuboCop · GitHub Actions
