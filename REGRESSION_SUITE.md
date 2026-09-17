# Manual Regression Suite — SauceDemo

Manual regression test cases for the SauceDemo web app, tracked the way I
track regression at work — a structured test-case sheet, not just automated
scripts. Automated coverage (login, sort, cart/checkout, API) lives in
`spec/` and `api_tests/`; this sheet covers additional exploratory and
edge-case scenarios better suited to manual execution, plus traceability
back to the automated cases.

| ID | Feature | Test Case | Steps | Expected Result | Priority | Status | Automated? |
|----|---------|-----------|-------|------------------|----------|--------|------------|
| RT-001 | Login | Valid login with standard_user | 1. Navigate to login page 2. Enter valid credentials 3. Submit | User lands on inventory page | High | Pass | ✅ `login_spec.rb` |
| RT-002 | Login | Locked out user is blocked | 1. Enter locked_out_user credentials 2. Submit | Error message: user locked out | High | Pass | ✅ `login_spec.rb` |
| RT-003 | Login | SQL injection attempt in username field | 1. Enter `' OR '1'='1` as username 2. Submit | Login rejected, no error leaking backend info | High | Pass | ❌ Manual only |
| RT-004 | Login | Session persists on page refresh | 1. Log in 2. Refresh browser | User remains logged in, on inventory page | Medium | Pass | ❌ Manual only |
| RT-005 | Inventory | Sort by price low→high | 1. Log in 2. Select "Price (low to high)" | Items reorder ascending by price | Medium | Pass | ✅ `inventory_spec.rb` |
| RT-006 | Inventory | Sort persists after adding item to cart | 1. Sort by name Z→A 2. Add an item to cart | Sort order unchanged after add | Low | Pass | ❌ Manual only |
| RT-007 | Inventory | Product image loads for every item | 1. Log in 2. Visually inspect each product card | No broken image icons | Low | Pass | ❌ Manual only |
| RT-008 | Cart | Add to cart updates badge count | 1. Add one item 2. Check cart icon | Badge shows "1" | High | Pass | ✅ `inventory_spec.rb` |
| RT-009 | Cart | Remove item from cart | 1. Add item 2. Go to cart 3. Remove item | Cart is empty, badge disappears | High | Pass | ✅ `cart_checkout_spec.rb` |
| RT-010 | Cart | Cart contents persist across navigation | 1. Add item 2. Navigate back to inventory 3. Return to cart | Item still present | Medium | Pass | ❌ Manual only |
| RT-011 | Checkout | Full happy-path checkout | 1. Add item 2. Checkout 3. Fill info 4. Finish | Order confirmation shown | High | Pass | ✅ `cart_checkout_spec.rb` |
| RT-012 | Checkout | Missing first name blocks checkout | 1. Start checkout 2. Leave first name blank 3. Continue | Error: first name is required | High | Pass | ✅ `cart_checkout_spec.rb` |
| RT-013 | Checkout | Cancel checkout returns to cart | 1. Start checkout step one 2. Click Cancel | User returned to cart, cart contents unchanged | Medium | Pass | ❌ Manual only |
| RT-014 | Checkout | Order total = item price + tax | 1. Complete checkout for a known-price item 2. Verify summary math | Total matches item price + displayed tax | Medium | Pass | ❌ Manual only |
| RT-015 | Cross-browser | Full checkout flow on Firefox | Repeat RT-011 on Firefox | Same behavior as Chrome | Medium | Pass | ❌ Manual only |
| RT-016 | Accessibility | Login form keyboard-only navigation | 1. Tab through username → password → login button 2. Submit with Enter key | Form fully usable without a mouse | Medium | Pass | ❌ Manual only |

## Traceability Matrix

Maps each requirement/user story to the test cases (manual + automated)
that verify it — the same purpose as the traceability sheet I maintain in
Excel at work, so gaps in coverage are visible at a glance.

| Requirement | Covered By | Coverage |
|---|---|---|
| User can log in with valid credentials | RT-001 | Full |
| Locked-out accounts cannot log in | RT-002 | Full |
| Login form resists basic injection attempts | RT-003 | Full |
| Session state is stable across refresh | RT-004 | Full |
| Products can be sorted by price and name | RT-005, RT-006 | Full |
| Product catalog renders correctly | RT-007 | Full |
| Cart accurately reflects added/removed items | RT-008, RT-009, RT-010 | Full |
| Checkout completes successfully with valid data | RT-011 | Full |
| Checkout validates required fields | RT-012 | Full |
| Checkout can be safely abandoned | RT-013 | Full |
| Order totals calculate correctly | RT-014 | Full |
| Core flow works across supported browsers | RT-015 | Partial — Chrome + Firefox only, Safari not yet covered |
| Core flows are keyboard-accessible | RT-016 | Partial — login only, checkout not yet covered |

**Known gaps:** Safari coverage and full keyboard-accessibility coverage
for checkout are tracked but not yet executed — flagged here rather than
silently omitted, same as I'd flag them in a real test-status report.
