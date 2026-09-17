# SauceDemo Test Automation Framework (Ruby)

This is a Selenium + RSpec suite that tests [saucedemo.com](https://www.saucedemo.com/),
a demo shopping site built for practicing automation. I built it in the stack I
actually use day to day — Ruby, RSpec, Selenium — and structured it the same way
I'd structure a real test framework at work: organized in layers so changes to
the app don't mean editing the same thing in ten different places.

There's also a [Python/pytest version](https://github.com/lola-olorode/saucedemo-portfolio)
of this exact same project, built the same way — mainly to show the same
approach carries across stacks, not just this one.

## What's being tested

- **The app:** [saucedemo.com](https://www.saucedemo.com/), a React site made for this
  exact purpose. It comes with a few test accounts that each behave differently —
  `standard_user` (works normally), `locked_out_user` (blocked at login), and
  `performance_glitch_user` (runs slow on purpose) — so the suite has real edge
  cases to test against, not just the happy path.
- **The API:** [reqres.in](https://reqres.in/), a free public API made for testing
  against, used by the `api_tests/` suite.
- **Browser:** Chrome, and it runs headless (no visible window) by default — set
  `HEADED=1` if you want to actually watch it click through the site.
- **Environment:** defaults to `prod` (the live public site); `TEST_ENV=staging`
  switches it, to show how a real project would target different environments
  without touching spec code.

## How it's organized

```
saucedemo-ruby/
├── components/               # UI pieces reused across pages (e.g. the burger menu)
│   └── menu_component.rb
├── flows/                     # Chains page actions into a full journey (log in, buy something)
│   ├── auth_flow.rb            # Login journeys
│   ├── shopping_flow.rb        # Sort / add-to-cart journeys
│   └── checkout_flow.rb        # Full checkout journey
├── pages/                     # One class per screen — the Page Object Model
│   ├── login_page.rb
│   ├── inventory_page.rb
│   ├── cart_page.rb
│   └── checkout_page.rb
├── shared/
│   ├── base_page.rb              # Wait/interaction helpers every page uses
│   ├── base_flow.rb              # Shared step-logging every flow uses
│   ├── environments.rb           # dev/staging/prod-style environment switching
│   └── utils/
│       ├── logger.rb              # Logs each run to file and console
│       └── screenshot.rb          # Grabs a screenshot the moment a spec fails
├── dataloader/                # Test data lives in JSON, not hardcoded in specs
│   ├── fixtures/
│   │   ├── users.json
│   │   └── checkout_info.json
│   ├── user_loader.rb
│   └── checkout_data_loader.rb
├── api_tests/                 # API tests, separate from the browser specs
│   ├── api_client.rb
│   └── users_api_spec.rb
├── api-testing/                # A standalone Postman collection (see its own README)
├── spec/
│   ├── spec_helper.rb           # Driver lifecycle, logged-in helper, failure hook
│   ├── core/                     # One file per feature/screen
│   ├── sweeps/                    # Full end-to-end journeys (smoke + regression)
│   └── unit/                      # Specs for the framework's own code, no browser needed
├── .github/workflows/            # CI: RuboCop first, then the suite, on every push
├── .rubocop.yml                  # Lint rules (annotated where they diverge from defaults)
├── Gemfile
├── Rakefile
└── .rspec
```

**Why split it up like this:**

A **page object** only knows how to click and read things on one screen — it has
no idea *why* it's being used.

A **flow** sits above that and knows the actual business journey, like "log in"
or "buy something," by stringing page objects together. So a spec that needs to
add an item and check out just calls one flow method, instead of repeating the
same four steps in every spec. And if the checkout screen changes, I fix it in
one flow file instead of everywhere it's used.

**Components** are UI bits shared across many pages (here, the burger menu), so
its locators live in exactly one place instead of being copy-pasted.

**Shared** holds the stuff every page and flow needs regardless of feature —
waiting for elements, logging, environment config.

**dataloader** treats test data as data: it lives in JSON files, and adding a
new test account is just editing a file, not touching code.

Inside `spec/`:
  - **core** covers individual features and their edge cases in isolation.
  - **sweeps** covers full journeys start to finish — a fast **smoke** version
    that runs on every commit, and a broader **regression** version meant for
    before a release. They're split apart because they run at different times
    for different reasons.
  - **unit** tests the framework's own logic, like environment selection and
    fixture loading, with no browser involved at all — `spec_helper.rb` only
    spins up Chrome for specs under `core/` and `sweeps/`, so unit specs stay fast.

There are also two ways of testing the API:
  `api_tests/` is automated and runs in CI on every push, while
  `api-testing/` is a Postman collection for the kind of manual, exploratory API checking that actually happens day to day on a real team.
  See [`api-testing/README.md`](./api-testing/README.md) for that one.

Everything runs through **GitHub Actions**: it lints the code first (RuboCop),
and only runs the full suite if that passes.

## What each spec actually checks

### Login — [`spec/core/login_spec.rb`](./spec/core/login_spec.rb)

**Lands on the inventory page with valid credentials.** Logs in as
`standard_user` and checks the inventory page actually loads — this is the
first thing that has to work, since nothing else matters if login is broken.

**Blocks a locked-out user.** Logs in as `locked_out_user` and checks the login
page shows a "locked out" error instead of letting them through.

**Shows the right error for bad credentials.** Runs the same check three ways:
nothing entered at all, a real username with no password, and a made-up
username/password pair — each should show its own matching error message.

### Inventory — [`spec/core/inventory_spec.rb`](./spec/core/inventory_spec.rb)

Sorting by price low-to-high, high-to-low, and by name A-to-Z — each one checks
the list actually ends up in the right order. Plus **adding an item updates the
cart badge**: starts at 0, adds one item, checks it shows 1.

### Cart & checkout — [`spec/core/cart_checkout_spec.rb`](./spec/core/cart_checkout_spec.rb)

**Removing an item from the cart** works and actually empties it back out.
**A full checkout, start to finish** adds an item, goes through checkout, and
checks for the "Thank you" confirmation at the end — this is the main "does
the site still work" test. **Checkout blocks a missing first name** — leaves
that field blank and checks the right validation error shows up.

### Full journeys, start to finish — [`spec/sweeps/`](./spec/sweeps)

The **smoke sweep** ([`smoke_sweep_spec.rb`](./spec/sweeps/smoke_sweep_spec.rb))
does one complete run — log in, add something to the cart, check out — as
`standard_user`. It runs on every commit as a quick "is anything fundamentally
broken" check, separate from the more detailed, isolated checks in `spec/core/`.

The **regression sweep**
([`regression_sweep_spec.rb`](./spec/sweeps/regression_sweep_spec.rb)) repeats
that same full journey, but across both `standard_user` and
`performance_glitch_user`. It's meant to run before a release rather than on
every commit — it's about testing the same journey across different accounts,
not new edge cases.

### API tests — [`api_tests/users_api_spec.rb`](./api_tests/users_api_spec.rb)

These hit [reqres.in](https://reqres.in/) directly, no browser involved: fetching
a single user and checking its shape (status code, fields, headers, response
time), fetching a paginated list, a 404 for a user that doesn't exist, creating,
updating, and deleting a user, and one check that confirms `GET` requests work
fine with no API key at all. That last one is there on purpose — I checked it
directly against the live API first, so if reqres.in ever tightens that up, this
spec will catch it as a clear failure instead of just quietly becoming wrong.

### Testing the framework itself — [`spec/unit/`](./spec/unit)

**`environments_spec.rb`** checks environment selection: it defaults to `prod`
when `TEST_ENV` isn't set, picks up the right config for `staging`, and raises
a clear error for an environment that doesn't exist.

**`user_loader_spec.rb`** checks fixture loading: a known user key returns the
right username/password, and an unknown key raises a clear error instead of
failing silently.

Neither of these opens a browser — that's the point of keeping them separate
from `core/` and `sweeps/`.

### The manual side

Not everything belongs in an automated spec. A manual regression suite and a
requirement-traceability matrix (which requirement maps to which test, automated
or not) live in [`REGRESSION_SUITE.md`](./REGRESSION_SUITE.md), so the gaps in
automated coverage are visible instead of hidden.

## A couple of things worth knowing

Some elements on saucedemo.com are built in React and quietly ignore a normal
Selenium click or `send_keys` call — the click looks like it worked, but
nothing actually happens on the page. So `BasePage#click` and `#type_text`
check that the native action really landed (a listener confirms the click
fired; typed text is checked against the field afterward) before falling back
to firing the event via JavaScript instead. It always tries the normal way
first — the fallback only kicks in when the normal way demonstrably didn't
work, rather than switching every interaction to JS and losing that realism
everywhere.

## Getting it running

```bash
bundle install
bundle exec rubocop                  # lint
bundle exec rake spec              # full suite — headless by default, no browser window appears
bundle exec rake unit                # framework-logic specs only, no browser
bundle exec rake api                 # just the API suite, no browser
bundle exec rspec spec/sweeps        # full-journey sweeps only
HEADED=1 bundle exec rspec spec/core  # watch it happen in an actual Chrome window
TEST_ENV=staging bundle exec rspec     # point it at a different environment
```

**On Windows / PowerShell** (VS Code's built-in terminal, for example), you have
to set environment variables as their own line instead of putting them before
the command:

```powershell
bundle install
bundle exec rubocop
bundle exec rake spec

$env:HEADED = "1"
bundle exec rspec spec/core          # watch it happen in an actual Chrome window

$env:TEST_ENV = "staging"
bundle exec rspec                     # point it at a different environment
```

`$env:HEADED` stays set for the rest of that terminal session — open a fresh
terminal, or run `Remove-Item Env:HEADED`, to go back to running headless.

## Where to find the results

Reports land in `reports/` — logs, screenshots of anything that failed, and a
JUnit XML file for CI to pick up.

## Links

- Repo: [github.com/lola-olorode/saucedemo-ruby-automation](https://github.com/lola-olorode/saucedemo-ruby-automation)
- CI runs: [Actions tab](https://github.com/lola-olorode/saucedemo-ruby-automation/actions)
- Same framework, in Python: [`saucedemo-portfolio`](https://github.com/lola-olorode/saucedemo-portfolio)

## Built with

Ruby · Selenium WebDriver · RSpec · HTTParty · RuboCop · Postman/Newman · GitHub Actions
